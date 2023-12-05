
create or replace function spellchecker(sentence string)
returns string
language python
runtime_version = '3.8'
handler = 'check_sentence_spelling'
packages = ('nltk')
imports = ('@spellcheckerstage/nltk_data.zip')
as
$$

import re
import json
import fcntl
import os
import sys
import threading
import zipfile

# File lock class for synchronizing write access to /tmp
class FileLock:
   def __enter__(self):
      self._lock = threading.Lock()
      self._lock.acquire()
      self._fd = open('/tmp/lockfile.LOCK', 'w+')
      fcntl.lockf(self._fd, fcntl.LOCK_EX)

   def __exit__(self, type, value, traceback):
      self._fd.close()
      self._lock.release()

# Get the location of the import directory. Snowflake sets the import
# directory location so code can retrieve the location via sys._xoptions.
IMPORT_DIRECTORY_NAME = "snowflake_import_directory"
import_dir = sys._xoptions[IMPORT_DIRECTORY_NAME]

# Get the path to the ZIP file and set the location to extract to.
zip_file_path = import_dir + "nltk_data.zip"
extracted = '/tmp/nltk_data_pkg_dir'

# Extract the contents of the ZIP. This is done under the file lock
# to ensure that only one worker process unzips the contents.
with FileLock():
   if not os.path.isdir(extracted + '/nltk_data'):
      with zipfile.ZipFile(zip_file_path, 'r') as myzip:
         myzip.extractall(extracted)

sys.path.append(extracted + '/nltk_data')


import nltk
nltk.data.path.append(extracted + '/nltk_data')
from nltk.corpus import words
from nltk.metrics.distance import jaccard_distance 
from nltk.util import ngrams
import re
import json
correct_words = words.words()

def check_sentence_spelling(sentence):
    words = sentence.split()
    words = [word.lower() for word in words]
    words = [re.sub(r'[^A-Za-z0-9]+', '', word) for word in words]
    errorcount = 0
    errors = {}
    errorlist = list(set(words).difference(correct_words))
    
    for word in errorlist:
        temp = [(jaccard_distance(set(ngrams(word, 2)), 
                          set(ngrams(w, 2))),w) 
             for w in correct_words if w[0]==word[0]] 
        suggestion = sorted(temp, key = lambda val:val[0])[0][1]
        errors[word] = suggestion
        errorcount = errorcount + 1
    
    iscorrect = "N" if errorcount > 0  else "Y"   
    result = {
      "iscorrect": iscorrect,
      "errorcount": errorcount,  
      "errors": errors
    }
    result_json = json.dumps(result)
    return result_json
  
$$;