*** Settings ***

Library  RequestsLibrary
Library  JSONLibrary
Library  XML

*** Variables ***
${base_url}     http://10.4.0.68:8081/payment/services/RequestMgrService
${callback_url}     http://172.31.255.36:8080/api/v1/callback
${Mpesa_TID}    RBG21M6W2Y
${uuid}=    Evaluate    uuid.uuid4()    modules=uuid


*** Test Cases ***
TC_001_Successful_OTC_Reversal_Request
#create the session
    Create Session  otc_reversal_session   ${base_url}

    ${xml}=        set variable      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:req="http://api-v1.gen.mm.vodafone.com/mminterface/request"><soapenv:Header/><soapenv:Body><req:RequestMsg><![CDATA[<?xml version="1.0" encoding="UTF-8"?><Request><Identity><Caller><CallerType>2</CallerType><ThirdPartyID>broker_4</ThirdPartyID><Password>llSlqPs/y9XT2sjq1xanxzlVvHOSpC3Jj0uShhIkE5FYRpYsV+ajYtW9cZZKxvSm3Zy1ApLzhm3fcbK8JoEuQ8Nz7EqXdJZJuaH7/sJb8EOhzED4ltbZpHeSP/uRuvfseI9vUJRV+H3lx8dfQ+Ae+hxUH02+BAxsaMVCiwsmdbr38ifzRImZcypHtHK4M+bY6E3vB28h+NHg0W68T3J+h8IZ1dcJOkHVaVMOaMjYZbnxR6eBhJ7DR6kY8FZ/mFdKSVI9rsHJ7e0jjsnzINy3UvqHaMeG2/RclF27dgoG8KioLVWVwwZT/gjimglmp2m3R+il+fTBgRZQu06lyYPe4w==</Password><ResultURL>${callback_url}</ResultURL></Caller><Initiator><IdentifierType>14</IdentifierType><Identifier>agentInit</Identifier><SecurityCredential>meM//Jt8k1DX9Qgl0dxsyOe7wqqRfq2w7Vzz/BZlQzbfReA0u3StdgwpAhIlbwgYWLtf0TgxCYOWwFRQnafuHyoZ7RGbhYcD+JiGgW8QJR64H6AT09FEHm4plF6ejzKZhvnvhgpXm/S0H9jdX+WTrlcKpm7e2NEQ5n7gMzpQht/RR77/X89SFQXbYMkNRw1tBuCouxWxlKy/FMS8LPRKQfIYxCywO017LMKanGz7NLux+p56Tlabgg94oZCbk9VfaKpi+EASbXQHgegU+1TrZA1xx6XRvllQVmDQzKBDUUQ1aJ0jLTLJfOuF01VxxwbGXQxKeNxAOwpE4hILgSumYw==</SecurityCredential></Initiator></Identity><Transaction><CommandID>TransactionReversal</CommandID><OriginatorConversationID>${uuid}</OriginatorConversationID><Timestamp>20130402152345</Timestamp><Parameters><Parameter><Key>OriginalTransactionID</Key><Value>${Mpesa_TID}</Value></Parameter></Parameters></Transaction><KeyOwner>1</KeyOwner></Request>]]></req:RequestMsg></soapenv:Body></soapenv:Envelope>
    #Make call and capture response in a variable
    ${response}=   POST On Session  otc_reversal_session   ${base_url}     data=${xml}

    #parse xml response
    ${xml_body}=    parse xml       ${response.content}

    #get inner response message
    ${response_msg}=    get element text    ${xml_body}         .//Body/ResponseMsg

    #parse inner response xml
    ${xml_internal}=    parse xml       ${response_msg}

    #pick value to validate
    #approach 1
    ${response_desc}=    get element text    ${xml_internal}         .//ResponseDesc
#    log to console  ${response_desc}
#
    should be equal     ${response_desc}        Accept the service request successfully.


#
#    #approach 2
#    ${response_desc}=    get element     ${xml_internal}         .//ResponseDesc
#    should be equal     ${response_desc.text}        Accept the service request successfully.
#
#    #approach 3
##    element text should be      ${xml_internal}    Accept the service request successfully.        .//ResponseDesc

#TC_002_Successful_Trx_Callback
###create the session
##    Create Session  callback_session   ${callback_url}
#    Sleep       5s
#    #Make call and capture response in a variable
#    ${response}=   GET On Session  otc_reversal_session   ${callback_url}
#
#    #parse xml response
#    ${xml_body}=    parse xml       ${response.content}
#
#    #get inner response message
#    ${response_msg}=    get element text    ${xml_body}         .//Body/ResultMsg
#
#    #parse inner response xml
#    ${xml_internal}=    parse xml       ${response_msg}
#
#    #pick value to validate
#    #approach 1
#    ${response_desc}=    get element text    ${xml_internal}         .//ResultDesc
##    ${response_tid}=    get element text    ${xml_internal}         .//TransactionID
#    ${original_tid}=    get element text    ${xml_internal}         .//ResultParameters/ResultParameter[5]/Value
#    log to console      ${original_tid}
#
###
#    should be equal     ${response_desc}        The service request is processed successfully.
#
#    should be equal     ${Mpesa_TID}            ${original_tid}

TC_001_Already_Reversed_Callback
    Sleep       5s
    #Make call and capture response in a variable
    ${response}=   GET On Session  otc_reversal_session   ${callback_url}

    #parse xml response
    ${xml_body}=    parse xml       ${response.content}

    #get inner response message
    ${response_msg}=    get element text    ${xml_body}         .//Body/ResultMsg

    #parse inner response xml
    ${xml_internal}=    parse xml       ${response_msg}

    #pick value to validate
    #approach 1
    ${response_desc}=    get element text    ${xml_internal}         .//ResultDesc

    should be equal     ${response_desc}        The transaction has already been reversed.

#TC_002_OTC_Reversal_Invalid_Pin
#
#    ${xml}=        set variable      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:req="http://api-v1.gen.mm.vodafone.com/mminterface/request"><soapenv:Header/><soapenv:Body><req:RequestMsg><![CDATA[<?xml version="1.0" encoding="UTF-8"?><Request><Identity><Caller><CallerType>2</CallerType><ThirdPartyID>broker_4</ThirdPartyID><Password>E5FYRpYsV+ajYtW9cZZKxvSm3Zy1ApLzhm3fcbK8JoEuQ8Nz7EqXdJZJuaH7/sJb8EOhzED4ltbZpHeSP/uRuvfseI9vUJRV+H3lx8dfQ+Ae+hxUH02+BAxsaMVCiwsmdbr38ifzRImZcypHtHK4M+bY6E3vB28h+NHg0W68T3J+h8IZ1dcJOkHVaVMOaMjYZbnxR6eBhJ7DR6kY8FZ/mFdKSVI9rsHJ7e0jjsnzINy3UvqHaMeG2/RclF27dgoG8KioLVWVwwZT/gjimglmp2m3R+il+fTBgRZQu06lyYPe4w==</Password><ResultURL>${callback_url}</ResultURL></Caller><Initiator><IdentifierType>14</IdentifierType><Identifier>JeyTestInitiator</Identifier><SecurityCredential>ochi6plXUfh6NJS3uPNwBL0noxy5mEatMtQr/U8fRhlr6IbxtSn7TY/KhWj+CLqkiXEC4S8fmxtMzZvlC0a3l4kEifx4aEHsMxqikiRwByE7DGd+VO2QQc5yyzIKPFZ3UYCkxW4jIQ8t6rnfftPXnj4po+3OPo8F4ito2Orn2UszAuu7JR7jl+SHC8Ot9ai40Vj/u41So0gjx8iOfjuT5AEHGzxaQzyI3tGU0ysrfVzQORJnIY2DYH7izcdwj8tapfxUQca/99b+eGJty+Up9rEDdFk0o00ClWvp9oiuG0NlQJe+GqUYtEIQbOk6Xof5xUGdPSfiyjSB07FE2gfn5g==</SecurityCredential></Initiator></Identity><Transaction><CommandID>TransactionReversal</CommandID><OriginatorConversationID>${uuid}</OriginatorConversationID><Timestamp>20130402152345</Timestamp><Parameters><Parameter><Key>OriginalTransactionID</Key><Value>RB681M2BDY</Value></Parameter></Parameters></Transaction><KeyOwner>1</KeyOwner></Request>]]></req:RequestMsg></soapenv:Body></soapenv:Envelope>
#
#    #Make call and capture response in a variable
#    ${response}=   POST On Session  otc_reversal_session   ${base_url}     data=${xml}
#
#    #parse xml response
#    ${xml_body}=    parse xml       ${response.content}
#
#    #get inner response message
#    ${response_msg}=    get element text    ${xml_body}         .//Body/ResponseMsg
#
#    #parse inner response xml
#    ${xml_internal}=    parse xml       ${response_msg}
#
#    #pick value to validate
#    #approach 1
#    ${response_desc}=    get element text    ${xml_internal}         .//ResponseDesc
##    log to console  ${response_desc}
##
#    should be equal     ${response_desc}        The caller information is invalid.
#
#TC_003_OTC_Reversal_Wrong_CommandID
#
#    ${xml}=        set variable      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:req="http://api-v1.gen.mm.vodafone.com/mminterface/request"><soapenv:Header/><soapenv:Body><req:RequestMsg><![CDATA[<?xml version="1.0" encoding="UTF-8"?><Request><Identity><Caller><CallerType>2</CallerType><ThirdPartyID>broker_4</ThirdPartyID><Password>llSlqPs/y9XT2sjq1xanxzlVvHOSpC3Jj0uShhIkE5FYRpYsV+ajYtW9cZZKxvSm3Zy1ApLzhm3fcbK8JoEuQ8Nz7EqXdJZJuaH7/sJb8EOhzED4ltbZpHeSP/uRuvfseI9vUJRV+H3lx8dfQ+Ae+hxUH02+BAxsaMVCiwsmdbr38ifzRImZcypHtHK4M+bY6E3vB28h+NHg0W68T3J+h8IZ1dcJOkHVaVMOaMjYZbnxR6eBhJ7DR6kY8FZ/mFdKSVI9rsHJ7e0jjsnzINy3UvqHaMeG2/RclF27dgoG8KioLVWVwwZT/gjimglmp2m3R+il+fTBgRZQu06lyYPe4w==</Password><ResultURL>${callback_url}</ResultURL></Caller><Initiator><IdentifierType>14</IdentifierType><Identifier>JeyTestInitiator</Identifier><SecurityCredential>ochi6plXUfh6NJS3uPNwBL0noxy5mEatMtQr/U8fRhlr6IbxtSn7TY/KhWj+CLqkiXEC4S8fmxtMzZvlC0a3l4kEifx4aEHsMxqikiRwByE7DGd+VO2QQc5yyzIKPFZ3UYCkxW4jIQ8t6rnfftPXnj4po+3OPo8F4ito2Orn2UszAuu7JR7jl+SHC8Ot9ai40Vj/u41So0gjx8iOfjuT5AEHGzxaQzyI3tGU0ysrfVzQORJnIY2DYH7izcdwj8tapfxUQca/99b+eGJty+Up9rEDdFk0o00ClWvp9oiuG0NlQJe+GqUYtEIQbOk6Xof5xUGdPSfiyjSB07FE2gfn5g==</SecurityCredential></Initiator></Identity><Transaction><CommandID>TransactionReversals</CommandID><OriginatorConversationID>${uuid}</OriginatorConversationID><Timestamp>20130402152345</Timestamp><Parameters><Parameter><Key>OriginalTransactionID</Key><Value>RB681M2BDY</Value></Parameter></Parameters></Transaction><KeyOwner>1</KeyOwner></Request>]]></req:RequestMsg></soapenv:Body></soapenv:Envelope>
#
#    #Make call and capture response in a variable
#    ${response}=   POST On Session  otc_reversal_session   ${base_url}     data=${xml}
#
#    #parse xml response
#    ${xml_body}=    parse xml       ${response.content}
#
#    #get inner response message
#    ${response_msg}=    get element text    ${xml_body}         .//Body/ResponseMsg
#
#    #parse inner response xml
#    ${xml_internal}=    parse xml       ${response_msg}
#
#    #pick value to validate
#    #approach 1
#    ${response_desc}=    get element text    ${xml_internal}         .//ResponseDesc
##    log to console  ${response_desc}
##
#    should be equal     ${response_desc}        The CommandID is invalid.
#
#TC_004_OTC_Reversal_Wrong_KeyOwner
#
#
#    ${xml}=        set variable      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:req="http://api-v1.gen.mm.vodafone.com/mminterface/request"><soapenv:Header/><soapenv:Body><req:RequestMsg><![CDATA[<?xml version="1.0" encoding="UTF-8"?><Request><Identity><Caller><CallerType>2</CallerType><ThirdPartyID>broker_4</ThirdPartyID><Password>llSlqPs/y9XT2sjq1xanxzlVvHOSpC3Jj0uShhIkE5FYRpYsV+ajYtW9cZZKxvSm3Zy1ApLzhm3fcbK8JoEuQ8Nz7EqXdJZJuaH7/sJb8EOhzED4ltbZpHeSP/uRuvfseI9vUJRV+H3lx8dfQ+Ae+hxUH02+BAxsaMVCiwsmdbr38ifzRImZcypHtHK4M+bY6E3vB28h+NHg0W68T3J+h8IZ1dcJOkHVaVMOaMjYZbnxR6eBhJ7DR6kY8FZ/mFdKSVI9rsHJ7e0jjsnzINy3UvqHaMeG2/RclF27dgoG8KioLVWVwwZT/gjimglmp2m3R+il+fTBgRZQu06lyYPe4w==</Password><ResultURL>${callback_url}</ResultURL></Caller><Initiator><IdentifierType>14</IdentifierType><Identifier>JeyTestInitiator</Identifier><SecurityCredential>ochi6plXUfh6NJS3uPNwBL0noxy5mEatMtQr/U8fRhlr6IbxtSn7TY/KhWj+CLqkiXEC4S8fmxtMzZvlC0a3l4kEifx4aEHsMxqikiRwByE7DGd+VO2QQc5yyzIKPFZ3UYCkxW4jIQ8t6rnfftPXnj4po+3OPo8F4ito2Orn2UszAuu7JR7jl+SHC8Ot9ai40Vj/u41So0gjx8iOfjuT5AEHGzxaQzyI3tGU0ysrfVzQORJnIY2DYH7izcdwj8tapfxUQca/99b+eGJty+Up9rEDdFk0o00ClWvp9oiuG0NlQJe+GqUYtEIQbOk6Xof5xUGdPSfiyjSB07FE2gfn5g==</SecurityCredential></Initiator></Identity><Transaction><CommandID>TransactionReversals</CommandID><OriginatorConversationID>${uuid}</OriginatorConversationID><Timestamp>20130402152345</Timestamp><Parameters><Parameter><Key>OriginalTransactionID</Key><Value>RB681M2BDY</Value></Parameter></Parameters></Transaction><KeyOwner>0</KeyOwner></Request>]]></req:RequestMsg></soapenv:Body></soapenv:Envelope>
#
#    #Make call and capture response in a variable
#    ${response}=   POST On Session  otc_reversal_session   ${base_url}     data=${xml}
#
#    #parse xml response
#    ${xml_body}=    parse xml       ${response.content}
#
#    #get inner response message
#    ${response_msg}=    get element text    ${xml_body}         .//Body/ResponseMsg
#
#    #parse inner response xml
#    ${xml_internal}=    parse xml       ${response_msg}
#
#    #pick value to validate
#    #approach 1
#    ${response_desc}=    get element text    ${xml_internal}         .//ResponseDesc
##    log to console  ${response_desc}
##
#    should be equal     ${response_desc}        Parameter missing or data type error.
#
#TC_005_Successful_Business_Transfer
#
#    ${xml}=        set variable     <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:req="http://api-v1.gen.mm.vodafone.com/mminterface/request"><soapenv:Header></soapenv:Header><soapenv:Body><req:RequestMsg><![CDATA[<?xml version='1.0' encoding='UTF-8'?><Request xmlns="http://api-v1.gen.mm.vodafone.com/mminterface/request"><Transaction><CommandID>AgentToSPWithdrawalsHoldingTransfer</CommandID><LanguageCode>0</LanguageCode><OriginatorConversationID>${uuid}</OriginatorConversationID><ConversationID/><Remark>0</Remark><Parameters><Parameter><Key>Amount</Key><Value>5500</Value></Parameter><Parameter><Key>ReasonType</Key><Value>Organization Withdrawal of Funds via API</Value></Parameter></Parameters><ReferenceData><ReferenceItem><Key>QueueTimeoutURL</Key><Value>${callback_url}</Value></ReferenceItem></ReferenceData><Timestamp>2014-09-27T12:53:19.0000521Z</Timestamp></Transaction><Identity><Caller><CallerType>2</CallerType><ThirdPartyID>broker_4</ThirdPartyID><Password>T50mhFnEwrPNy0BU0b+n+8Hwdb2LhsKG0KSPemuiXiZrcYoemz5vIl0uUzs1OSUPi5cumPF4djZuuIERNVA+znH85Iy2k+DQQtFRGTVKBWNZZpDjus9RE0BD7iuBFjiAzr5UNJcpeetSO0nmG7O9sfXJ/tBWCnRPRE8vWNzlrq0tBhFl1EtWvkBDY7Daj/MWeigkumOGwB0/GDvO0AsOJZtHuGeddGHEi/lb1oJxlCOKXts8ZxopnbuDN5sB4qD3P5QUxgTfE1KFHEeklvwWUcnNpuDz7q12k0yzYhsJEE4MyiVwjZVuo66TPQd4AjU+JDzEIAwG4IJx98dh5C4AOA==</Password><ResultURL>${callback_url}</ResultURL></Caller><Initiator><IdentifierType>14</IdentifierType><Identifier>agentInit</Identifier><SecurityCredential>meM//Jt8k1DX9Qgl0dxsyOe7wqqRfq2w7Vzz/BZlQzbfReA0u3StdgwpAhIlbwgYWLtf0TgxCYOWwFRQnafuHyoZ7RGbhYcD+JiGgW8QJR64H6AT09FEHm4plF6ejzKZhvnvhgpXm/S0H9jdX+WTrlcKpm7e2NEQ5n7gMzpQht/RR77/X89SFQXbYMkNRw1tBuCouxWxlKy/FMS8LPRKQfIYxCywO017LMKanGz7NLux+p56Tlabgg94oZCbk9VfaKpi+EASbXQHgegU+1TrZA1xx6XRvllQVmDQzKBDUUQ1aJ0jLTLJfOuF01VxxwbGXQxKeNxAOwpE4hILgSumYw==</SecurityCredential></Initiator><PrimaryParty><IdentifierType>4</IdentifierType><Identifier>243900</Identifier><ShortCode>243900</ShortCode></PrimaryParty><ReceiverParty><IdentifierType>3</IdentifierType><Identifier>1</Identifier></ReceiverParty></Identity><KeyOwner>1</KeyOwner></Request>]]></req:RequestMsg></soapenv:Body></soapenv:Envelope>
#
#
#    #Make call and capture response in a variable
#    ${response}=   POST On Session  otc_reversal_session   ${base_url}     data=${xml}
#
#    #parse xml response
#    ${xml_body}=    parse xml       ${response.content}
#
#    #get inner response message
#    ${response_msg}=    get element text    ${xml_body}         .//Body/ResponseMsg
#
#    #parse inner response xml
#    ${xml_internal}=    parse xml       ${response_msg}
#
#    #pick value to validate
#    #approach 1
#    ${response_desc}=    get element text    ${xml_internal}         .//ResponseDesc
##    log to console  ${response_desc}
##
#    should be equal     ${response_desc}        Accept the service request successfully.
#
#TC_005_Business_Transfer_Invalid_CommandID
#
#    ${xml}=        set variable     <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:req="http://api-v1.gen.mm.vodafone.com/mminterface/request"><soapenv:Header></soapenv:Header><soapenv:Body><req:RequestMsg><![CDATA[<?xml version='1.0' encoding='UTF-8'?><Request xmlns="http://api-v1.gen.mm.vodafone.com/mminterface/request"><Transaction><CommandID>AgentToSPWithdrawalsHoldingTransfers</CommandID><LanguageCode>0</LanguageCode><OriginatorConversationID>${uuid}</OriginatorConversationID><ConversationID/><Remark>0</Remark><Parameters><Parameter><Key>Amount</Key><Value>5500</Value></Parameter><Parameter><Key>ReasonType</Key><Value>Organization Withdrawal of Funds via API</Value></Parameter></Parameters><ReferenceData><ReferenceItem><Key>QueueTimeoutURL</Key><Value>${callback_url}</Value></ReferenceItem></ReferenceData><Timestamp>2014-09-27T12:53:19.0000521Z</Timestamp></Transaction><Identity><Caller><CallerType>2</CallerType><ThirdPartyID>broker_4</ThirdPartyID><Password>T50mhFnEwrPNy0BU0b+n+8Hwdb2LhsKG0KSPemuiXiZrcYoemz5vIl0uUzs1OSUPi5cumPF4djZuuIERNVA+znH85Iy2k+DQQtFRGTVKBWNZZpDjus9RE0BD7iuBFjiAzr5UNJcpeetSO0nmG7O9sfXJ/tBWCnRPRE8vWNzlrq0tBhFl1EtWvkBDY7Daj/MWeigkumOGwB0/GDvO0AsOJZtHuGeddGHEi/lb1oJxlCOKXts8ZxopnbuDN5sB4qD3P5QUxgTfE1KFHEeklvwWUcnNpuDz7q12k0yzYhsJEE4MyiVwjZVuo66TPQd4AjU+JDzEIAwG4IJx98dh5C4AOA==</Password><ResultURL>${callback_url}</ResultURL></Caller><Initiator><IdentifierType>14</IdentifierType><Identifier>agentInit</Identifier><SecurityCredential>meM//Jt8k1DX9Qgl0dxsyOe7wqqRfq2w7Vzz/BZlQzbfReA0u3StdgwpAhIlbwgYWLtf0TgxCYOWwFRQnafuHyoZ7RGbhYcD+JiGgW8QJR64H6AT09FEHm4plF6ejzKZhvnvhgpXm/S0H9jdX+WTrlcKpm7e2NEQ5n7gMzpQht/RR77/X89SFQXbYMkNRw1tBuCouxWxlKy/FMS8LPRKQfIYxCywO017LMKanGz7NLux+p56Tlabgg94oZCbk9VfaKpi+EASbXQHgegU+1TrZA1xx6XRvllQVmDQzKBDUUQ1aJ0jLTLJfOuF01VxxwbGXQxKeNxAOwpE4hILgSumYw==</SecurityCredential></Initiator><PrimaryParty><IdentifierType>4</IdentifierType><Identifier>243900</Identifier><ShortCode>243900</ShortCode></PrimaryParty><ReceiverParty><IdentifierType>3</IdentifierType><Identifier>1</Identifier></ReceiverParty></Identity><KeyOwner>1</KeyOwner></Request>]]></req:RequestMsg></soapenv:Body></soapenv:Envelope>
#
#    #Make call and capture response in a variable
#    ${response}=   POST On Session  otc_reversal_session   ${base_url}     data=${xml}
#
#    #parse xml response
#    ${xml_body}=    parse xml       ${response.content}
#
#    #get inner response message
#    ${response_msg}=    get element text    ${xml_body}         .//Body/ResponseMsg
#
#    #parse inner response xml
#    ${xml_internal}=    parse xml       ${response_msg}
#
#    #pick value to validate
#    #approach 1
#    ${response_desc}=    get element text    ${xml_internal}         .//ResponseDesc
##    log to console  ${response_desc}
##
#    should be equal     ${response_desc}        The CommandID is invalid.
#
#TC_005_Business_Transfer_Invalid_Caller_ID
#
#    ${xml}=        set variable     <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:req="http://api-v1.gen.mm.vodafone.com/mminterface/request"><soapenv:Header></soapenv:Header><soapenv:Body><req:RequestMsg><![CDATA[<?xml version='1.0' encoding='UTF-8'?><Request xmlns="http://api-v1.gen.mm.vodafone.com/mminterface/request"><Transaction><CommandID>AgentToSPWithdrawalsHoldingTransfer</CommandID><LanguageCode>0</LanguageCode><OriginatorConversationID>${uuid}</OriginatorConversationID><ConversationID/><Remark>0</Remark><Parameters><Parameter><Key>Amount</Key><Value>5500</Value></Parameter><Parameter><Key>ReasonType</Key><Value>Organization Withdrawal of Funds via API</Value></Parameter></Parameters><ReferenceData><ReferenceItem><Key>QueueTimeoutURL</Key><Value>${callback_url}</Value></ReferenceItem></ReferenceData><Timestamp>2014-09-27T12:53:19.0000521Z</Timestamp></Transaction><Identity><Caller><CallerType>3</CallerType><ThirdPartyID>broker_4</ThirdPartyID><Password>T50mhFnEwrPNy0BU0b+n+8Hwdb2LhsKG0KSPemuiXiZrcYoemz5vIl0uUzs1OSUPi5cumPF4djZuuIERNVA+znH85Iy2k+DQQtFRGTVKBWNZZpDjus9RE0BD7iuBFjiAzr5UNJcpeetSO0nmG7O9sfXJ/tBWCnRPRE8vWNzlrq0tBhFl1EtWvkBDY7Daj/MWeigkumOGwB0/GDvO0AsOJZtHuGeddGHEi/lb1oJxlCOKXts8ZxopnbuDN5sB4qD3P5QUxgTfE1KFHEeklvwWUcnNpuDz7q12k0yzYhsJEE4MyiVwjZVuo66TPQd4AjU+JDzEIAwG4IJx98dh5C4AOA==</Password><ResultURL>${callback_url}</ResultURL></Caller><Initiator><IdentifierType>14</IdentifierType><Identifier>agentInit</Identifier><SecurityCredential>meM//Jt8k1DX9Qgl0dxsyOe7wqqRfq2w7Vzz/BZlQzbfReA0u3StdgwpAhIlbwgYWLtf0TgxCYOWwFRQnafuHyoZ7RGbhYcD+JiGgW8QJR64H6AT09FEHm4plF6ejzKZhvnvhgpXm/S0H9jdX+WTrlcKpm7e2NEQ5n7gMzpQht/RR77/X89SFQXbYMkNRw1tBuCouxWxlKy/FMS8LPRKQfIYxCywO017LMKanGz7NLux+p56Tlabgg94oZCbk9VfaKpi+EASbXQHgegU+1TrZA1xx6XRvllQVmDQzKBDUUQ1aJ0jLTLJfOuF01VxxwbGXQxKeNxAOwpE4hILgSumYw==</SecurityCredential></Initiator><PrimaryParty><IdentifierType>4</IdentifierType><Identifier>243900</Identifier><ShortCode>243900</ShortCode></PrimaryParty><ReceiverParty><IdentifierType>3</IdentifierType><Identifier>1</Identifier></ReceiverParty></Identity><KeyOwner>1</KeyOwner></Request>]]></req:RequestMsg></soapenv:Body></soapenv:Envelope>
#
#
#    #Make call and capture response in a variable
#    ${response}=   POST On Session  otc_reversal_session   ${base_url}     data=${xml}
#
#    #parse xml response
#    ${xml_body}=    parse xml       ${response.content}
#
#    #get inner response message
#    ${response_msg}=    get element text    ${xml_body}         .//Body/ResponseMsg
#
#    #parse inner response xml
#    ${xml_internal}=    parse xml       ${response_msg}
#
#    #pick value to validate
#    #approach 1
#    ${response_desc}=    get element text    ${xml_internal}         .//ResponseDesc
##    log to console  ${response_desc}
##
#    should be equal     ${response_desc}        The caller information is invalid.