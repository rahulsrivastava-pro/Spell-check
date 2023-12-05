
import nltk
nltk.download('words') 
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

        
# sentence = 'This is a sentenceeee to checkk! sureeeee'
# output = check_sentence_spelling(sentence)
# print(output)