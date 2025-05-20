# spec/models/directory_spec.rb
require "rails_helper"

RSpec.describe Directory, type: :model do
  describe "associações entre diretórios" do
    it "permite que um diretório tenha vários subdiretórios, tipo pasta dentro de pasta" do
      root = create(:directory, name: "root")
      child1 = create(:directory, name: "child1", parent: root)
      child2 = create(:directory, name: "child2", parent: root)

      expect(root.subdirectories).to match_array([ child1, child2 ])
      expect(child1.parent).to eq(root)
      expect(child2.parent).to eq(root)
    end

    it "diretório raiz não tem pai, ele tá no topo da hierarquia" do
      root = create(:directory, name: "root")
      expect(root.parent).to be_nil
    end
  end

  describe "validações básicas, porque ninguém gosta de dados ruins" do
    subject { build(:directory) }

    it "nome é obrigatório, não dá pra deixar em branco" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "não rola ter dois diretórios com o mesmo nome no mesmo lugar — evitar confusão" do
      parent = create(:directory)
      create(:directory, name: "docs", parent: parent)
      duplicate = build(:directory, name: "docs", parent: parent)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "mas em pastas diferentes, nomes iguais são de boa" do
      parent1 = create(:directory)
      parent2 = create(:directory)
      create(:directory, name: "docs", parent: parent1)
      directory = build(:directory, name: "docs", parent: parent2)

      expect(directory).to be_valid
    end

    it "não permite dois diretórios raiz com o mesmo nome" do
      create(:directory, name: "docs", parent: nil)
      duplicate = build(:directory, name: "docs", parent: nil)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "não permite nome nulo mesmo com pai presente" do
      parent = create(:directory)
      dir = build(:directory, name: nil, parent: parent)

      expect(dir).not_to be_valid
      expect(dir.errors[:name]).to include("can't be blank")
    end

    it "não permite diretório órfão sem nome" do
      dir = build(:directory, name: nil, parent: nil)

      expect(dir).not_to be_valid
      expect(dir.errors[:name]).to include("can't be blank")
    end

    it "não permite parent_id inválido" do
      dir = build(:directory, name: "inválido", parent_id: 99999)

      expect(dir).not_to be_valid
      # expect(dir.errors[:parent]).to include("must exist")
      expect(dir.errors[:parent]).to include("deve se referir a um diretório existente")
    end
  end

  describe "validações estruturais — árvore consistente" do
    it "não deixa pai virar filho do filho (ciclo direto)" do
      root = create(:directory, name: "root")
      child = create(:directory, name: "child", parent: root)

      expect { root.update!(parent: child) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "não permite ser pai de si mesmo" do
      dir = create(:directory, name: "ciclico")

      expect { dir.update!(parent: dir) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "não permite ciclo indireto (nível 3)" do
      a = create(:directory, name: "a")
      b = create(:directory, name: "b", parent: a)
      c = create(:directory, name: "c", parent: b)

      expect { a.update!(parent: c) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "#dir_path — monta o caminho completo, tipo navegação de pastas" do
    it "junta tudo direitinho, de pai pra filho" do
      root = create(:directory, name: "root")
      sub1 = create(:directory, name: "sub1", parent: root)
      sub2 = create(:directory, name: "sub2", parent: sub1)

      expect(sub2.dir_path).to eq("root/sub1/sub2")
    end

    it "diretório raiz só retorna o próprio nome, sem frescura" do
      root = create(:directory, name: "root")
      expect(root.dir_path).to eq("root")
    end

    it "monta caminho com mais de 2 níveis" do
      grandpa = create(:directory, name: "root")
      parent = create(:directory, name: "sub", parent: grandpa)
      dir = create(:directory, name: "docs", parent: parent)

      expect(dir.dir_path).to eq("root/sub/docs")
    end
  end

  describe "exclusão e cascata, porque ninguém quer lixo sobrando" do
    it "remove tudo que tá dentro quando o pai for deletado" do
      root = create(:directory)
      child = create(:directory, parent: root)

      expect { root.destroy }.to change { Directory.count }.by(-2)
    end

    it "remove descendentes em cascata (3 níveis)" do
      root = create(:directory)
      child = create(:directory, parent: root)
      grandchild = create(:directory, parent: child)

      expect { root.destroy }.to change { Directory.count }.by(-3)
    end
  end
end
