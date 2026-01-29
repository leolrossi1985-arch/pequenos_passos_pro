# Guia de Migração e Configuração no Mac 🍎

Este arquivo contém o passo a passo para configurar o projeto **Pequenos Passos Pro** em um ambiente macOS, especialmente para compilar a versão iOS.

## 1. Pré-requisitos
Antes de começar, certifique-se de ter instalado:
1.  **Xcode**: Instale via App Store. Abra-o pelo menos uma vez para aceitar os termos de licença e instalar componentes adicionais.
2.  **Flutter SDK**: Siga o guia oficial (https://docs.flutter.dev/get-started/install/macos).
3.  **CocoaPods**: Gerenciador de dependências do iOS.
    ```bash
    sudo gem install cocoapods
    ```

## 2. Baixando o Projeto
Abra o terminal e clone o repositório (caso ainda não tenha feito):
```bash
git clone https://github.com/leolrossi1985-arch/pequenos_passos_pro.git
cd pequenos_passos_pro
```

## 3. Instalando Dependências do Projeto
1.  Baixe os pacotes do Flutter:
    ```bash
    flutter pub get
    ```

2.  Instale os Pods do iOS (Passo Crucial):
    ```bash
    cd ios
    pod install --repo-update
    cd ..
    ```
    *Nota: Se ocorrerem erros de versão, tente rodar `rm -rf Pods` e `rm Podfile.lock` dentro da pasta `ios` antes de rodar o `pod install` novamente.*

## 4. Configuração do Firebase (Já incluída)
O arquivo `GoogleService-Info.plist` já foi configurado e commitado na pasta `ios/Runner`. Não é necessário baixá-lo novamente, a menos que você crie um novo projeto no Firebase.

## 5. Abrindo e Rodando no Xcode
Para configurar a assinatura (Signing) e rodar no simulador/dispositivo:

1.  Abra o workspace do iOS:
    ```bash
    open ios/Runner.xcworkspace
    ```
    **Importante:** Sempre abra o arquivo `.xcworkspace` (ícone branco), nunca o `.xcodeproj`.

2.  Configurar Assinatura (Signing):
    *   No Xcode, clique em **Runner** (na barra lateral esquerda, ícone azul no topo).
    *   Selecione o **Target Runner** na área central.
    *   Vá na aba **Signing & Capabilities**.
    *   Em **Team**, selecione sua conta de desenvolvedor Apple (Personal Team é aceito para testes).
    *   Certifique-se que o **Bundle Identifier** é `com.leolr.zelo`.

3.  Executar:
    *   Selecione um simulador (ex: iPhone 15) no topo da janela.
    *   Clique no botão **Play** (triângulo).

## 6. Comandos Úteis
*   **Limpar cache (se der erro estranho):**
    ```bash
    flutter clean
    flutter pub get
    cd ios && pod install && cd ..
    ```
*   **Rodar via terminal:**
    ```bash
    flutter run
    ```
