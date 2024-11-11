# Rclone GUI

Projeto criado com o intuito de facilitar o manuseio da ferramenta rclone.

Ainda encontra-se em versão inicial, permitindo apenas fazer mount/unmount de armazenamentos remotos já configurados
via linha de comando. Se você ainda não possui nenhuma configuração do rclone, não será possível utilizar esta GUI.

# Funcionalidades

✅ Fazer mount (Google Drive)

✅ Controlar o nível de acesso do mount: Apenas leitura/Permitir escrita

✅ Montar para uma letra de drive (Windows)

❓Otimizar o cache para obter a prévia dos arquivos rapidamente

❌ Configurar armazenamentos remotos

❌ Personalizar configurações avançadas de mount

# Requisitos
Por si só, o Rclone **não** é capaz de realizar mounts em seu sistema. É necessário instalar um software adicional para
esta tarefa.

Para usuários Windows: instale o [winfsp](https://winfsp.dev/rel/).

Para usuários macOS: instale o [FUSE-T](https://www.fuse-t.org/).

**Isto não é um requisito gerado por este projeto**. Até mesmo nos casos onde o Rclone é utilizado puramente via linha
de comando, é necessário instalar os softwares mencionados acima.

# Compilando a partir do código fonte
A maravilha do código aberto é não precisar confiar em ninguém. Analise a fonte por conta própria e, quando concluir,
construa seu próprio executável para ter a certeza que nenhum agente malicioso foi introduzido no programa.

Este é um projeto Flutter que não requer nenhuma configuração especial para rodar o build. Sendo assim, basta seguir a
documentação oficial de build voltada para o seu sistema: 
[Windows](https://docs.flutter.dev/platform-integration/windows/building), 
[macOS](https://docs.flutter.dev/platform-integration/macos/building)
(Linux em breve!).

Nota os usuários que compilam para Windows: É necessário baixar o arquivo 
[sqlite3.dll](https://www.sqlite.org/download.html) e colocá-lo no mesmo diretório do executável compilado. Caso 
contrário, o programa não iniciará.

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