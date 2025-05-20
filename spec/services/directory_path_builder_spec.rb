RSpec.describe DirectoryPathService do
  describe '#build' do
    context 'com diretórios reais' do
      let(:root) { Directory.create!(name: 'root') }
      let(:child) { Directory.create!(name: 'child', parent: root) }
      let(:grandchild) { Directory.create!(name: 'grandchild', parent: child) }

      it 'retorna string vazia para nil' do
        expect(DirectoryPathService.new(nil).build).to eq('')
      end

      it 'retorna nome para diretório raiz' do
        expect(DirectoryPathService.new(root).build).to eq('root')
      end

      it 'concatena nomes do pai e filho' do
        expect(DirectoryPathService.new(child).build).to eq('root/child')
      end

      it 'concatena múltiplos níveis' do
        expect(DirectoryPathService.new(grandchild).build).to eq('root/child/grandchild')
      end
    end

    context 'com doubles' do
      let(:root) { instance_double('Directory', name: 'root', parent: nil) }
      let(:child) { instance_double('Directory', name: 'child', parent: root) }
      let(:grandchild) { instance_double('Directory', name: 'grandchild', parent: child) }

      it 'funciona com doubles simulando diretórios encadeados' do
        expect(DirectoryPathService.new(grandchild).build).to eq('root/child/grandchild')
      end
    end

    context 'com valores edge' do
      it 'retorna vazio se nome for nil' do
        dir = instance_double('Directory', name: nil, parent: nil)
        expect(DirectoryPathService.new(dir).build).to eq('')
      end

      it 'retorna vazio se nome for string vazia' do
        dir = instance_double('Directory', name: '', parent: nil)
        expect(DirectoryPathService.new(dir).build).to eq('')
      end

      # it 'retorna vazio se objeto não responde a name' do
      #   obj = double('FakeDirectory')
      #   allow(obj).to receive(:parent).and_return(nil)
      #   expect(DirectoryPathService.new(obj).build).to eq('')
      # end
    end
  end
end
