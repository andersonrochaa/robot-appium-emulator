# robot-appium-emulator

## Teste Robot: Abrir YouTube

Este repositório inclui um teste simples em Robot Framework para abrir a página inicial do YouTube usando Selenium.

### Dependências

Definidas em `pyproject.toml`:
- `robotframework`
- `robotframework-seleniumlibrary`
- `robotframework-appiumlibrary` (para futuros testes mobile, não usado neste caso)

Instale as dependências (exemplo usando Poetry):

```powershell
poetry install
```

Caso não use Poetry, pode instalar via pip dentro de um ambiente virtual:
```powershell
python -m venv .venv; .\.venv\Scripts\Activate.ps1
pip install robotframework robotframework-seleniumlibrary robotframework-appiumlibrary
```

### Driver do Navegador
Certifique-se de ter o Chrome instalado e um ChromeDriver compatível no PATH. Alternativas:
1. Baixar manualmente o ChromeDriver e adicionar a pasta ao PATH.
2. Usar WebDriver Manager (ex: `pip install webdriver-manager`) e ajustar inicialização (não necessário neste teste simples se o driver já estiver no PATH).

### Executar o Teste

Arquivo do teste: `tests/open_youtube.robot`

```powershell
robot tests/open_youtube.robot
```

### Personalizações
- Trocar `${BROWSER}` para `firefox` se tiver Geckodriver instalado.
- Ajustar timeout em `${TIMEOUT}` conforme velocidade da máquina.

### Estrutura
```
tests/
	open_youtube.robot
pyproject.toml
README.md
```

### Próximos Passos
- Adicionar testes mobile utilizando AppiumLibrary (abrir app YouTube ou navegador móvel).
- Parametrizar execução via variáveis de linha de comando (ex: `robot -v BROWSER:firefox ...`).

## Testes Mobile (Appium)

Arquivo: `tests/mobile_open_youtube.robot`

Contém dois cenários:
- Abrir o aplicativo YouTube (usando `appPackage`/`appActivity`).
- Abrir o YouTube no Chrome móvel.

### Variáveis em YAML
As variáveis de configuração dos testes mobile foram movidas para `config/mobile.yaml`. Para alterar dispositivo, pacote ou activity edite esse arquivo.

Exemplo de conteúdo:
```yaml
APPIUM_SERVER: "http://localhost:4723/wd/hub"
DEVICE_NAME: "emulator-5554"
PLATFORM_NAME: "Android"
AUTOMATION_NAME: "UiAutomator2"
YOUTUBE_PACKAGE: "com.google.android.youtube"
YOUTUBE_ACTIVITY: "com.google.android.youtube.HomeActivity"
YOUTUBE_URL: "https://www.youtube.com"
NO_RESET: true
```

O arquivo `tests/mobile_open_youtube.robot` referencia o YAML via:
```
Variables    ../config/mobile.yaml
```

### Pré-requisitos Android/Appium
1. Instalar SDK Android e criar/emulador (`avdmanager` / Android Studio).
2. Iniciar emulador (exemplo):
```powershell
$Env:ANDROID_HOME="C:\Android\Sdk"
$Env:PATH+=";${Env:ANDROID_HOME}\platform-tools;${Env:ANDROID_HOME}\emulator"
emulator -list-avds
emulator -avd Pixel_7_API_34
```
3. Verificar dispositivo:
```powershell
adb devices
```
4. Iniciar Appium Server (local):
```powershell
npx appium
# ou se instalado global: appium
```

### Executar teste App YouTube
```powershell
robot -v DEVICE_NAME:emulator-5554 tests/mobile_open_youtube.robot --test "Abrir App YouTube (Android)"
```

### Executar teste YouTube no Chrome
```powershell
robot -v DEVICE_NAME:emulator-5554 tests/mobile_open_youtube.robot --test "Abrir YouTube no Chrome (Android)"
```

Se a `appActivity` falhar, tente uma destas alternativas:
- `com.google.android.youtube.app.honeycomb.ShellActivity`
- Use `adb shell dumpsys activity activities | findstr youtube` para inspecionar.

### Parametrizações úteis
- `-v DEVICE_NAME:emulator-5556` para outro emulador.
- Adicionar `noReset=${True}` evita reinstalação/limpa estado.

### Dicas de Debug
- `adb logcat | findstr youtube`
- Tirar screenshot via AppiumLibrary: `Capture Page Screenshot`.

---
## CI (GitHub Actions)

O workflow `.github/workflows/robot-mobile-tests.yml`:
- Provisiona SDK Android API 34 e cria AVD headless.
- Inicia Appium server.
- Executa somente o caso Chrome mobile: `Abrir YouTube no Chrome (Android)`.
- Gravação de tela feita dentro de cada teste (após abrir a sessão Appium).
- Vídeo salvo como `results/video.mp4` e publicado junto de `robot-results`.

Para rodar local similar (Linux/Mac):
```bash
sdkmanager "platform-tools" "platforms;android-34" "emulator" "system-images;android-34;google_apis;x86_64"
echo "no" | avdmanager create avd -n localAvd -k "system-images;android-34;google_apis;x86_64"
emulator -avd localAvd -no-snapshot -no-audio -no-window &
# aguardar boot
while [ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; do echo "Aguardando boot"; sleep 5; done
appium &
robot -v DEVICE_NAME:emulator-5554 --test "Abrir YouTube no Chrome (Android)" tests/mobile_open_youtube.robot
```

Se quiser testar apenas gravação sem abrir Chrome, comente keywords de navegação e revise saída.

---

---
Qualquer dúvida sobre expansão para Appium, peça instruções.