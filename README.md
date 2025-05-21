# Sistema de Arquivos Persistente - Ruby on Rails

## Descrição

Este projeto implementa um sistema de arquivos persistido em banco de dados SQL, permitindo criar diretórios e arquivos, com suporte a subdiretórios e múltiplos tipos de armazenamento de arquivos (blob, S3 ou disco). O sistema foi desenvolvido em Ruby on Rails, seguindo princípios de Clean Code, SRP (Single Responsibility Principle) e com cobertura de testes automatizados.

---

## Regras de Negócio

- **Diretórios**
  - Podem conter subdiretórios e arquivos.
  - Diretórios podem ser aninhados em qualquer profundidade.
  - Diretórios raiz não possuem pai.
  - O nome do diretório é obrigatório e único dentro do mesmo diretório pai.
  - Não é permitido que um diretório seja pai de si mesmo ou de qualquer um de seus descendentes (evita ciclos).

- **Arquivos**
  - Todo arquivo pertence obrigatoriamente a um diretório.
  - O nome do arquivo é obrigatório e único dentro do diretório.
  - O conteúdo do arquivo pode ser armazenado como blob, S3 ou disco, utilizando Active Storage.
  - Suporte a diferentes tipos de armazenamento via enum (`file_type_storage`).

---

## Princípios de Projeto

- **Clean Code**
  - Nomes de classes, métodos e variáveis claros e autoexplicativos.
  - Separação de responsabilidades entre models, services e validações.
  - Métodos curtos e objetivos.
  - Comentários e documentação em pontos críticos.

- **SRP (Single Responsibility Principle)**
  - Models cuidam apenas de regras de dados e validações.
  - Services encapsulam lógicas de negócio específicas, como montagem de caminhos de diretórios e arquivos.
  - Validações customizadas centralizadas nos models.

- **Organização**
  - Models: `Directory`, `StorageFile`
  - Services: `DirectoryPathService`, `StorageFilePathService`
  - Testes: Cobrem models, services e casos de borda.

---

## Estrutura do Projeto

```
app/
  models/
    directory.rb
    storage_file.rb
  services/
    directory_path_service.rb
    storage_file_path_service.rb
  controllers/
    directories_controller.rb
    storage_files_controller.rb
  views/
    directories/
    storage_files/
  assets/
    stylesheets/
    images/
  javascript/
    controllers/
spec/
  models/
  services/
  requests/
  factories/
  rails_helper.rb
  spec_helper.rb
```

---

## Dicas Sênior para Rodar e Testar

### 1. **Dependências**

- Use a versão correta do Ruby e Rails conforme especificado no projeto.
- Instale todas as dependências:
  ```sh
  bundle install
  yarn install # se usar assets JS/CSS modernos
  ```

### 2. **Configuração do Banco de Dados**

- Crie e migre o banco:
  ```sh
  rails db:create db:migrate
  ```

### 3. **Rodando o Servidor**

- Inicie o servidor Rails:
  ```sh
  rails s
  ```
- Acesse em [http://localhost:3000](http://localhost:3000)

### 4. **Testes**

- Rode todos os testes:
  ```sh
  bundle exec rspec
  ```
- Visualize a cobertura de código (após rodar os testes):
  ```sh
  open coverage/index.html
  ```

### 5. **Testando S3 Localmente (com LocalStack)**

- Suba o LocalStack usando Docker Compose:
  ```sh
  docker-compose up -d
  ```
- Crie o bucket S3 usando AWS CLI:
  ```sh
  aws --endpoint-url=http://localhost:4566 s3 mb s3://test-bucket --region us-east-1 --no-sign-request
  ```
- Garanta que o serviço `test_s3` está configurado em `config/storage.yml` e selecionado no ambiente de teste.
- Rode os testes normalmente; uploads irão para o LocalStack.

### 6. **Testando Blob (no banco de dados)**

- O model suporta armazenar arquivos como blob no banco. Para isso, garanta que a coluna `blob_data` existe e use o valor `blob` no enum.
- **Atenção:** Armazenar arquivos grandes no banco não é recomendado para produção, mas é suportado para fins acadêmicos/demonstração.

### 7. **Problemas Comuns & Soluções**

- **Rota de download ausente:**  
  Certifique-se de que seu `routes.rb` inclui:
  ```ruby
  resources :directories do
    resources :storage_files do
      member do
        get :download
      end
    end
  end
  ```
- **Ação download não encontrada:**  
  Implemente a action `download` no `StorageFilesController` conforme mostrado no código.
- **Erro 406 Not Acceptable nos request specs:**  
  Use `as: :html` nos specs para garantir resposta HTML.

### 8. **CI/CD**

- Exemplo de workflow do GitHub Actions disponível em `.github/workflows/ci.yml`.
- Projeto pronto para testes automatizados a cada push/pull request.
- Usa PostgreSQL no ambiente de CI.

### 9. **Extensibilidade**

- O código é modular e pronto para novos tipos de armazenamento ou regras de negócio.
- Para adicionar novos backends de storage, basta estender o enum e implementar a lógica necessária.

### 10. **Boas Práticas Gerais**

- Mantenha os testes sempre atualizados ao adicionar novas features.
- Use factories para dados de teste, mantendo os specs limpos e fáceis de manter.
- Use service objects para lógicas de negócio que não pertencem a models ou controllers.
- Documente qualquer lógica customizada ou não óbvia diretamente no código.

---

## Autor

Desenvolvido por danieldjam  
Contato: [eu@danieldjam.dev.br]

# Lógica do Sistema de Arquivos Persistente - Ruby on Rails

## Visão Geral

O sistema implementa uma estrutura de arquivos e diretórios persistida em banco de dados SQL, permitindo criar, navegar, editar e excluir diretórios e arquivos. Os arquivos podem ser armazenados em três tipos de backend: como blob no banco, em disco local ou em S3 (compatível com AWS ou LocalStack).

---

## Estrutura de Dados

### Diretórios (`Directory`)

- **Hierarquia:**  
  Cada diretório pode ter um diretório pai (`parent_id`) e vários subdiretórios (`subdirectories`).  
  Isso permite criar árvores de diretórios de profundidade ilimitada.
- **Validações:**  
  - O nome é obrigatório e único entre os irmãos (mesmo diretório pai).
  - Não permite ciclos (um diretório não pode ser seu próprio pai ou descendente).
- **Métodos utilitários:**  
  - `dir_path`: retorna o caminho completo do diretório, usando um service para montar a string (ex: `raiz/subpasta/pasta`).

### Arquivos (`StorageFile`)

- **Associação:**  
  Todo arquivo pertence a um diretório.
- **Validações:**  
  - Nome obrigatório e único dentro do diretório.
- **Tipos de armazenamento:**  
  - Enum `file_type_storage` define se o arquivo será salvo como `blob` (no banco), `disk` (local) ou `s3` (remoto).
- **Conteúdo:**  
  - Se `blob`, o conteúdo é salvo na coluna `blob_data` (tipo binário).
  - Se `disk` ou `s3`, o arquivo é gerenciado pelo Active Storage.
- **Métodos utilitários:**  
  - `content_type`: retorna o conteúdo do arquivo conforme o tipo de armazenamento.
  - `file_path`: retorna o caminho completo do arquivo, usando um service.

---

## Serviços (`Services`)

- **DirectoryPathService:**  
  Responsável por montar o caminho completo de um diretório, concatenando os nomes dos ancestrais até o diretório atual.
- **StorageFilePathService:**  
  Responsável por montar o caminho completo de um arquivo, incluindo o caminho do diretório e o nome do arquivo.

---

## Controllers

### Diretórios (`DirectoriesController`)

- **index:** Lista todos os diretórios raiz.
- **show:** Exibe detalhes do diretório, subdiretórios e arquivos.
- **new/create:** Cria novos diretórios, podendo ser raiz ou subdiretórios.
- **edit/update:** Edita diretórios existentes.
- **destroy:** Remove diretórios e todos os seus descendentes (subdiretórios e arquivos).

### Arquivos (`StorageFilesController`)

- **index:** Lista arquivos de um diretório.
- **show:** Exibe detalhes de um arquivo.
- **new/create:** Cria arquivos em um diretório, escolhendo o tipo de armazenamento.
- **edit/update:** Edita arquivos existentes.
- **destroy:** Remove arquivos.
- **download:** Permite baixar o arquivo, independente do tipo de armazenamento:
  - Se `blob`, envia o conteúdo binário.
  - Se `disk` ou `s3`, redireciona para a URL gerada pelo Active Storage.

---

## Views

- **Diretórios:**  
  - Listagem, criação, edição e navegação entre subdiretórios.
  - Exibição dos arquivos contidos em cada diretório.
- **Arquivos:**  
  - Listagem, criação, edição e download.
  - Formulário permite escolher o tipo de armazenamento.

---

## Fluxo de Criação e Download de Arquivos

1. **Usuário acessa um diretório e escolhe "Adicionar Arquivo".**
2. **No formulário, seleciona o arquivo e o tipo de armazenamento (blob, disk, s3).**
3. **Ao salvar:**
   - Se `blob`, o conteúdo é salvo na coluna `blob_data`.
   - Se `disk` ou `s3`, o arquivo é salvo via Active Storage.
4. **Na listagem, cada arquivo tem um link de download.**
5. **Ao clicar em download:**
   - Se `blob`, o controller envia o conteúdo binário.
   - Se `disk` ou `s3`, o controller redireciona para a URL do Active Storage.

---

## Testes

- **Cobertura de models:**  
  Validações, associações, enums e métodos utilitários.
- **Cobertura de services:**  
  Montagem de caminhos, casos de borda e uso de doubles.
- **Cobertura de requests:**  
  Testes de controllers para garantir respostas corretas e integração entre camadas.

---

## Extensibilidade

- **Novo tipo de armazenamento:**  
  Basta adicionar ao enum e implementar a lógica correspondente no model/controller.
- **Novas regras de negócio:**  
  Adicione validações ou métodos utilitários conforme necessário.
- **Escalabilidade:**  
  Estrutura modular facilita manutenção e evolução do sistema.

---

## Dicas Sênior

- Use sempre services para lógica de negócio fora dos models/controllers.
- Mantenha os testes atualizados e com boa cobertura.
- Documente decisões arquiteturais e regras customizadas no README e no código.
- Prefira enums e validações contextuais para garantir integridade dos dados.
- Use ferramentas como LocalStack para testar integrações com S3 localmente.

---

## Resumo

O sistema é robusto, modular, seguro e pronto para produção ou evolução.  
Permite criar e gerenciar uma árvore de diretórios e arquivos, com múltiplos tipos de armazenamento, e está preparado para ser expandido conforme novas necessidades do negócio.

---