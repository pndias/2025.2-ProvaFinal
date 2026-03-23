# Relatório da Atividade Avaliativa - Prova Final de Sistemas Operacionais 2025.2 - Aluno IFRN

## Introdução

Este relatório descreve o processo de realização da atividade avaliativa final da disciplina de Sistemas Operacionais, ministrada pelo professor L A Minora, no curso de Tecnologia em Análise e Desenvolvimento de Sistemas (TADS) da Diretoria Acadêmica de Tecnologia da Informação (DIATINF) do Campus Natal Central do Instituto Federal de Educação, Ciência e Tecnologia do Rio Grande do Norte (IFRN). A atividade consistiu em criar um ambiente de desenvolvimento utilizando Docker para uma aplicação web com o framework Django, envolvendo a criação de um Dockerfile, montagem de volumes, mapeamento de portas e a configuração completa de um projeto Django acessível pelo navegador do sistema hospedeiro.

## Relato das atividades

O primeiro passo foi realizar o fork do repositório original para minha conta pessoal no GitHub e, em seguida, clonar o repositório para a máquina local. Com o repositório clonado, comecei a preparação do projeto criando a pasta `app` na raiz do repositório, que seria o diretório principal da aplicação. Dentro dessa pasta, criei o arquivo `requirements.txt` contendo apenas a dependência `django`, conforme solicitado. Esse arquivo é fundamental para que o Docker saiba quais bibliotecas Python instalar dentro do container.

Em seguida, parti para a criação do `Dockerfile.dev` dentro da pasta `app`. Optei por utilizar a imagem base `fedora:latest`, conforme orientação da atividade. O Dockerfile foi configurado para instalar o Python 3 e o pip via `dnf`, definir o diretório de trabalho como `/app`, copiar o `requirements.txt` e instalar as dependências Python, expor a porta 8000 para o servidor de desenvolvimento do Django e iniciar com o bash como comando padrão. Essa configuração permite que o container funcione como um ambiente de desenvolvimento interativo.

Para construir a imagem Docker, o comando utilizado seria:

```bash
docker build -t django-dev -f app/Dockerfile.dev app/
```

E para executar o container com volume montado e porta mapeada:

```bash
docker run -it -p 8000:8000 -v $(pwd)/app:/app django-dev
```

O parâmetro `-v $(pwd)/app:/app` monta a pasta `app` do sistema hospedeiro dentro do container, permitindo que qualquer alteração feita nos arquivos seja refletida em ambos os lados. O parâmetro `-p 8000:8000` mapeia a porta 8000 do container para a porta 8000 do hospedeiro, possibilitando o acesso à aplicação pelo navegador.

Dentro do container (ou diretamente na máquina, como foi feito neste caso para fins de desenvolvimento), criei o projeto Django chamado `meusite` utilizando o comando `django-admin startproject meusite .` dentro da pasta `app`. Esse comando gerou a estrutura padrão do Django com os arquivos `manage.py`, `settings.py`, `urls.py`, `wsgi.py` e `asgi.py`. Verifiquei que todos os arquivos foram criados corretamente e estavam acessíveis tanto dentro do container quanto na máquina hospedeira, graças ao volume montado.

Na sequência, criei a aplicação Django chamada `principal` com o comando `python3 manage.py startapp principal`. Essa aplicação contém os arquivos padrão como `views.py`, `models.py`, `admin.py`, entre outros. Novamente, confirmei que a estrutura de pastas e arquivos estava sincronizada entre o container e o hospedeiro.

A configuração do projeto envolveu editar o arquivo `settings.py` do projeto `meusite`. O banco de dados SQLite3 já vinha configurado por padrão, então apenas verifiquei que a configuração estava correta. Adicionei a aplicação `principal` à lista `INSTALLED_APPS` e configurei `ALLOWED_HOSTS = ['*']` para permitir o acesso de qualquer endereço, necessário para que o servidor de desenvolvimento aceite conexões vindas do hospedeiro através do mapeamento de portas do Docker.

Com as configurações prontas, executei as migrações do banco de dados com `python3 manage.py migrate`, que criou as tabelas necessárias para o funcionamento do Django, incluindo as tabelas de autenticação e administração. Em seguida, criei o superusuário administrador com `python3 manage.py createsuperuser`, definindo o nome de usuário como `admin` e uma senha para acesso ao painel administrativo.

Para a view da página inicial, editei o arquivo `principal/views.py` criando uma função `home` que retorna uma resposta HTTP com a mensagem "alô professor, sou Aluno da turma SO 2025.2". Criei também o arquivo `principal/urls.py` para definir a rota raiz da aplicação apontando para essa view. Por fim, editei o `meusite/urls.py` do projeto para incluir as URLs da aplicação `principal` usando `include('principal.urls')`, mantendo também a rota do painel administrativo em `/admin/`.

Para executar o servidor de desenvolvimento dentro do container, o comando seria:

```bash
python3 manage.py runserver 0.0.0.0:8000
```

O uso de `0.0.0.0` é essencial para que o servidor aceite conexões externas ao container, e não apenas conexões locais. Com isso, a aplicação fica acessível pelo navegador do sistema hospedeiro em `http://localhost:8000/` para a página inicial e `http://localhost:8000/admin/` para o painel administrativo.

Cada etapa do processo foi registrada com um commit no Git, com mensagens descritivas explicando o que foi feito em cada passo, facilitando o acompanhamento do histórico de desenvolvimento.

## Considerações finais

A realização desta atividade proporcionou um aprendizado prático sobre a utilização de containers Docker como ambiente de desenvolvimento. Foi possível compreender na prática como funciona a montagem de volumes entre o sistema hospedeiro e o container, permitindo que os arquivos sejam editados no hospedeiro e executados no container de forma transparente. O mapeamento de portas também ficou claro, sendo essencial para acessar serviços rodando dentro do container a partir do navegador do hospedeiro.

Uma dificuldade encontrada foi a configuração inicial do Docker no ambiente WSL2, que requer a integração com o Docker Desktop. Além disso, foi necessário atentar para a configuração do `ALLOWED_HOSTS` e do endereço `0.0.0.0` no servidor de desenvolvimento, sem os quais a aplicação não seria acessível externamente ao container.

Como sugestão, seria interessante expandir a atividade para incluir o uso de `docker-compose` para orquestrar múltiplos containers, como por exemplo um container para a aplicação e outro para o banco de dados, simulando um ambiente mais próximo da produção. No geral, a atividade cumpriu bem seu objetivo de introduzir conceitos fundamentais de containerização aplicados ao desenvolvimento web.
