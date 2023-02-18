*** Settings ***

Library  RequestsLibrary
Library  Selenium2Library
Library  JSONLibrary

*** Variables ***
${base_url}     http://10.4.0.68:8081/payment/services/RequestMgrService

*** Keywords ***
Post Request

 #create the session
    Create Session  otc_reversal_session   ${base_url}

${body} =   <soapenv:Envelope
		xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
		xmlns:req="http://api-v1.gen.mm.vodafone.com/mminterface/request">
   <soapenv:Header/>
   <soapenv:Body>
      <req:RequestMsg><![CDATA[<?xml version="1.0" encoding="UTF-8"?>
	      <Request>
		   <Identity>
		      <Caller>
		         <CallerType>2</CallerType>
		         <ThirdPartyID>broker_4</ThirdPartyID>
		         <Password>llSlqPs/y9XT2sjq1xanxzlVvHOSpC3Jj0uShhIkE5FYRpYsV+ajYtW9cZZKxvSm3Zy1ApLzhm3fcbK8JoEuQ8Nz7EqXdJZJuaH7/sJb8EOhzED4ltbZpHeSP/uRuvfseI9vUJRV+H3lx8dfQ+Ae+hxUH02+BAxsaMVCiwsmdbr38ifzRImZcypHtHK4M+bY6E3vB28h+NHg0W68T3J+h8IZ1dcJOkHVaVMOaMjYZbnxR6eBhJ7DR6kY8FZ/mFdKSVI9rsHJ7e0jjsnzINy3UvqHaMeG2/RclF27dgoG8KioLVWVwwZT/gjimglmp2m3R+il+fTBgRZQu06lyYPe4w==</Password>
		         <ResultURL>http://${=InetAddress.localHost.getHostAddress()}:15588/callback</ResultURL>
		      </Caller>
		      <Initiator>
         <IdentifierType>14</IdentifierType>
         <Identifier>JeyTestInitiator</Identifier>
         <SecurityCredential>ochi6plXUfh6NJS3uPNwBL0noxy5mEatMtQr/U8fRhlr6IbxtSn7TY/KhWj+CLqkiXEC4S8fmxtMzZvlC0a3l4kEifx4aEHsMxqikiRwByE7DGd+VO2QQc5yyzIKPFZ3UYCkxW4jIQ8t6rnfftPXnj4po+3OPo8F4ito2Orn2UszAuu7JR7jl+SHC8Ot9ai40Vj/u41So0gjx8iOfjuT5AEHGzxaQzyI3tGU0ysrfVzQORJnIY2DYH7izcdwj8tapfxUQca/99b+eGJty+Up9rEDdFk0o00ClWvp9oiuG0NlQJe+GqUYtEIQbOk6Xof5xUGdPSfiyjSB07FE2gfn5g==</SecurityCredential>
      </Initiator>
		   </Identity>
		   <Transaction>
		      <CommandID>TransactionReversal</CommandID>
		      <OriginatorConversationID>${=java.util.UUID.randomUUID()}</OriginatorConversationID>
		      <Timestamp>20130402152345</Timestamp>
		      <Parameters>
                   <Parameter>
                       <Key>OriginalTransactionID</Key>
                       <Value>RB681M2BDY</Value>
                   </Parameter>
               </Parameters>
		   </Transaction>
		   <KeyOwner>1</KeyOwner>
		</Request>
      ]]></req:RequestMsg>
   </soapenv:Body>
</soapenv:Envelope>


    #Make call and capture response in a variable
    ${response} =   POST On Session  otc_reversal_session   data=${body}


#    # Check the response status
##    Should be Equal As Strings   ${response.status_code}    200
#
#     ${xml} =    convert to string   ${response.content()}

     log to console  ${response.content}


#*** Test Cases ***


#    ${json} =    Set Variable   ${response.content()}
#    Should be Equal As Strings  ${json['login']}    devmwatha
#    Log  ${json}
