*** Settings ***
Library    AppiumLibrary    timeout=30    implicit_wait=5
Library    OperatingSystem
Variables  ../config/mobile.yaml
Suite Setup    Iniciar Gravação
Suite Teardown    Parar Gravação E Salvar Video

# Ajuste DEVICE_NAME conforme saída de: adb devices
# Se a atividade principal falhar, tente: com.google.android.youtube.app.honeycomb.ShellActivity

*** Test Cases ***
Abrir App YouTube (Android)
    [Documentation]    Abre o aplicativo YouTube no emulador e verifica se carregou algum elemento principal.
    Open Application    ${APPIUM_SERVER}    platformName=${PLATFORM_NAME}    deviceName=${DEVICE_NAME}    automationName=${AUTOMATION_NAME}    appPackage=${YOUTUBE_PACKAGE}    appActivity=${YOUTUBE_ACTIVITY}    noReset=${NO_RESET}
    Wait Until Any Elements Visible    xpath=//android.widget.ImageView[contains(@content-desc,'Pesquisar')]    xpath=//android.widget.ImageView[contains(@content-desc,'Search')]    20s
    Log    YouTube app aberto com sucesso.
    [Teardown]    Close Application

Abrir YouTube no Chrome (Android)
    [Documentation]    Abre Chrome móvel e navega para a homepage do YouTube.
    Open Application    ${APPIUM_SERVER}    platformName=${PLATFORM_NAME}    deviceName=${DEVICE_NAME}    automationName=${AUTOMATION_NAME}    browserName=Chrome
    Go To Url    ${YOUTUBE_URL}
    Wait Until Page Contains    YouTube    20s
    Log    Página YouTube carregada no Chrome móvel.
    [Teardown]    Close Application

*** Keywords ***
Wait Until Any Elements Visible
    [Arguments]    @{locators}    ${timeout}=10s
    FOR    ${loc}    IN    @{locators}
        Run Keyword And Ignore Error    Wait Until Element Is Visible    ${loc}    ${timeout}
        ${status}    ${msg}=    Run Keyword And Return Status    Element Should Be Visible    ${loc}
        IF    ${status}
            Return From Keyword
        END
    END
    Fail    Nenhum dos elementos ficou visível dentro do timeout.
Iniciar Gravação
    Start Screen Recording
Parar Gravação E Salvar Video
    ${b64}=    Stop Screen Recording
    Save Base64 Video    ${b64}    artifacts/videos/mobile-youtube.mp4
    Log    Vídeo salvo em artifacts/videos/mobile-youtube.mp4
Save Base64 Video
    [Arguments]    ${data}    ${path}
    Create Directory    artifacts/videos
    ${decoded}=    Evaluate    __import__('base64').b64decode(${data})
    Create File    ${path}    ${decoded}    encoding=None
