# Sistema de Arquivos Persistente - Ruby on Rails

## Descrição

Este projeto implementa um sistema de arquivos persistido em banco de dados SQL, onde é possível criar diretórios e arquivos, com suporte a subdiretórios e múltiplos tipos de armazenamento de arquivos (blob, S3 ou disco). O sistema foi desenvolvido em Ruby on Rails, seguindo princípios de Clean Code, SRP (Single Responsibility Principle) e com cobertura de testes automatizados.

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
  assets/
    stylesheets/
    images/
    config/
  javascript/
    controllers/
  views/
    layouts/
    pwa/
spec/
  models/
  services/
  factories/
  rails_helper.rb
  spec_helper.rb
```

---

## Testes

- **Framework:** RSpec
- **Cobertura:** Utiliza SimpleCov para medir cobertura de código.
- **Tipos de Teste:**
  - **Unitários:** Models e services.
  - **Integração:** Criação de diretórios e arquivos, validação de regras de negócio, exclusão em cascata.
  - **Casos de borda:** Nomes nulos, ciclos, diretórios órfãos, etc.

### Como rodar os testes

```sh
bundle exec rspec
```

### Como visualizar a cobertura

```sh
open coverage/index.html
```

---

## CI/CD

- **CI:** Exemplo de configuração com GitHub Actions disponível para rodar testes automaticamente em cada push/pull request.
- **Arquivo de workflow:** `.github/workflows/ci.yml`
- **Banco de dados:** PostgreSQL configurado para ambiente de CI.

---

## Como rodar o projeto localmente

1. Instale as dependências:
   ```sh
   bundle install
   yarn install # se usar assets JS/CSS modernos
   ```

2. Configure o banco de dados:
   ```sh
   rails db:create db:migrate
   ```

3. Rode o servidor:
   ```sh
   rails s
   ```

4. Acesse em [http://localhost:3000](http://localhost:3000)

---

## Observações

- O projeto está preparado para expansão, com fácil integração de novos tipos de armazenamento ou regras de negócio.
- Mensagens de erro e validações são claras e amigáveis.
- Código pronto para produção, seguindo padrões de projetos Rails de alta qualidade.

---

## Autor

Desenvolvido por danieldjam  
Contato: [eu@danieldjam.dev.br]
