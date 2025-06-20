# Rclone GUI

Projeto criado com o intuito de facilitar o manuseio da ferramenta rclone.

Ainda encontra-se em versão inicial, portanto esteja preparado para encontrar bugs ou comportamentos estranhos.
Caso algo não saia conforme esperado, por favor, [abra uma issue](https://github.com/Treech3r/Rclone-GUI/issues/new)
para que eu fique ciente e corrija o mais rápido possível.

OBS.: Apesar de ser possível executar o projeto em ambientes Linux, eu não testo ativamente nessa plataforma.

# Funcionalidades

✅ Configurar armazenamentos remotos

✅ Fazer montagem dos armazenamentos remotos

# Requisitos
Por si só, o Rclone **não** é capaz de realizar mounts em seu sistema. É necessário instalar um software adicional para
esta tarefa. **Isto não é um requisito gerado por este projeto**. Até mesmo nos casos onde o Rclone é utilizado puramente
via linha de comando, é necessário instalar os softwares mencionados abaixo.

Para Windows, instale o [winfsp](https://winfsp.dev/rel/).

Para macOS, instale o [FUSE-T](https://www.fuse-t.org/).

Para Linux, é necessário a biblioteca `fuse3`, que geralmente já vem instalada por padrão nas distros mais populares.

# Compilando a partir do código fonte
A maravilha do código aberto é dispensar o fator confiança. Analise o código fonte por conta própria e
construa seu próprio executável para ter a certeza que nenhum agente malicioso foi introduzido no programa.

Este é um projeto Flutter Desktop que não requer nenhuma configuração especial para rodar o build. Sendo assim, basta clonar este
repositório e seguir a documentação oficial de build voltada para o seu sistema: 
[Windows](https://docs.flutter.dev/platform-integration/windows/building), 
[macOS](https://docs.flutter.dev/platform-integration/macos/building),
[Linux](https://docs.flutter.dev/platform-integration/linux/building).

# Executáveis pré-compilados
Para aqueles que não desejam passar pelo processo de construir seu próprio executável ou baixar arquivos externos, é
possível encontrar executáveis já compilados por mim mesmo na 
[seção de lançamentos](https://github.com/Treech3r/Rclone-GUI/releases) deste repositório. Lá você encontrará todas as
versões passadas e futuras deste projeto.

# Licença

Este projeto está sob a licença **GNU General Public License (GPL) 3.0**, que permite aos usuários usar, modificar e
distribuir o código, mas exige que qualquer versão modificada ou redistribuída também seja de código aberto e esteja
sob a mesma licença, garantindo a liberdade de uso e proteção contra restrições como patentes e DRM.

Para ver o texto completo da licença, leia o arquivo [COPYING](COPYING).
