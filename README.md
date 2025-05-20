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