*** Settings ***
Library    AppiumLibrary    timeout=30
Library    OperatingSystem

# Ajuste DEVICE_NAME conforme saída de: adb devices
# Se a atividade principal falhar, tente: com.google.android.youtube.app.honeycomb.ShellActivity

*** Variables ***
${APPIUM_SERVER}      http://localhost:4723/wd/hub
${DEVICE_NAME}        emulator-5554
${YOUTUBE_URL}        https://www.youtube.com

*** Test Cases ***
Abrir YouTube e esperar 20s (Android)
    [Documentation]    Abre o Chrome móvel, navega até o YouTube e espera 20s.
    [Setup]    Iniciar Gravacao Tela
    Open Application    ${APPIUM_SERVER}    platformName=Android    deviceName=${DEVICE_NAME}    automationName=UiAutomator2    browserName=Chrome
    Go To Url    ${YOUTUBE_URL}
    Sleep    20s
    [Teardown]    Parar Gravacao E Fechar

*** Keywords ***
Iniciar Gravacao Tela
    Start Screen Recording

Parar Gravacao E Fechar
    ${b64}=    Stop Screen Recording
    ${bin}=    Evaluate    __import__('base64').b64decode(${b64})
    Create Binary File    ${OUTPUT DIR}/video.mp4    ${bin}
    Close Application

