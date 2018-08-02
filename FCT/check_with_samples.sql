column script new_value SCRIPT
select case when '&WITH_SAMPLES.' = 'Y'
            then '&1.' 
            else 'null.sql' end script
  from dual;
  
@&script.