*** Settings ***

Library  RequestsLibrary
Library  Selenium2Library
Library  JSONLibrary

*** Variables ***
${base_url}     http://10.4.0.68:8081/payment/services/RequestMgrServices/

*** Keywords ***
Post Request


 #create the session
    Create Session  reversal_session   ${base_url}

${body} =  


    #Make call and capture response in a variable
    ${response} =   post request  reversal_session   data=${body}


    # Check the response status
    Should be Equal As Strings   ${response.status_code}    200

     ${xml} =    convert to string   ${response.content()}

     log to console  ${xml}


#*** Test Cases ***


#    ${json} =    Set Variable   ${response.content()}
#    Should be Equal As Strings  ${json['login']}    devmwatha
#    Log  ${json}