*** Settings ***
Documentation  These are API Tests
Resource   ../Resources/API/api.robot
*** Variables ***

*** Test Cases ***
Make a simple REST API call for Github users
    [Tags]  Sanity
    Post Request

*** Keywords ***
