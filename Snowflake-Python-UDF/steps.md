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