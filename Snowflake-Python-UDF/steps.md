1. Take the "nltk_data.zip" file and push it to Snowflake Internal Stage 
2. Push this to Snowflake Managed Stage [Use Admin Account that will execute this function]
   1. Goto DB 
      1. Goto Schema 
         1. Add Stage 
            1. SnowflakeManaged
               1. Name: spellcheckerstage 
3. Execute the "udf.sql"
4. Test It
   1. Select SPELLCHECKER('This is a sentenceererere to checkk!')
5. Result [Example]: 
   
    {
        "iscorrect": "N", ["Y" or "N" depending if the senetence is correct]
        "errorcount": 3,  [gives count of spelling mistakes]
        "errors":         [list of misspelled words and the suggestions for correct word]
            {
            "sentenceeee": "sentence", 
            "sureeeee": "sure", 
            "checkk": "check"
            }
    }

   
6. Added the python file - "spellchecker.py" for checking the UDF logic and future extensions 