RSpec.describe StorageFilePathService do
  let(:separator) { "/" }

  context 'com objeto storage_file válido' do
    let(:directory) { instance_double('Directory', dir_path: 'root/child') }
    let(:storage_file) { instance_double('StorageFile', name: 'file.txt', directory: directory) }
    subject { described_class.new(storage_file, separator: separator) }

    it 'monta caminho completo com separador padrão' do
      expect(subject.call).to eq('root/child/file.txt')
    end

    it 'monta caminho com separador customizado' do
      service = described_class.new(storage_file, separator: "|")
      expect(service.call).to eq('root/child|file.txt')
    end
  end

  context 'quando storage_file não tem diretório' do
    let(:storage_file) { instance_double('StorageFile', name: 'file.txt', directory: nil) }
    subject { described_class.new(storage_file) }

    it 'retorna apenas o nome do arquivo' do
      expect(subject.call).to eq('file.txt')
    end
  end

  context 'valores edge e proteções' do
    it 'retorna string vazia se storage_file for nil' do
      service = described_class.new(nil)
      expect(service.call).to eq('')
    end

    it 'retorna string vazia se storage_file não responder a :name' do
      obj = double('FakeStorageFile')
      allow(obj).to receive(:respond_to?).with(:name).and_return(false)
      expect(described_class.new(obj).call).to eq('')
    end

    it 'retorna string vazia se storage_file.name for nil' do
      storage_file = instance_double('StorageFile', name: nil)
      allow(storage_file).to receive(:respond_to?).with(:name).and_return(true)
      expect(described_class.new(storage_file).call).to eq('')
    end

    it 'retorna string vazia se storage_file.name for string vazia' do
      storage_file = instance_double('StorageFile', name: '')
      allow(storage_file).to receive(:respond_to?).with(:name).and_return(true)
      expect(described_class.new(storage_file).call).to eq('')
    end

    it 'retorna nome do arquivo mesmo se storage_file não responder a :directory' do
      storage_file = double('StorageFile', name: 'file.txt')
      allow(storage_file).to receive(:respond_to?).with(:name).and_return(true)
      allow(storage_file).to receive(:respond_to?).with(:directory).and_return(false)
      expect(described_class.new(storage_file).call).to eq('file.txt')
    end

    it 'ignora directory se não responder a :dir_path' do
      directory = double('Directory')
      allow(directory).to receive(:respond_to?).with(:dir_path).and_return(false)
      storage_file = double('StorageFile', name: 'file.txt', directory: directory)
      allow(storage_file).to receive(:respond_to?).with(:name).and_return(true)
      allow(storage_file).to receive(:respond_to?).with(:directory).and_return(true)
      expect(described_class.new(storage_file).call).to eq('file.txt')
    end

    it 'retorna nome do arquivo se directory.dir_path for nil' do
      directory = double('Directory', dir_path: nil)
      storage_file = double('StorageFile', name: 'file.txt', directory: directory)
      # allow(storage_file).to receive(:respond_to?).and_call_original
      allow(storage_file).to receive(:respond_to?).with(:name).and_return(true)
      allow(storage_file).to receive(:respond_to?).with(:directory).and_return(true)
      expect(described_class.new(storage_file).call).to eq('file.txt')
    end

     it 'retorna nome do arquivo se directory.dir_path for string vazia' do
       directory = double('Directory', dir_path: '')
       storage_file = double('StorageFile', name: 'file.txt', directory: directory)
       # allow(storage_file).to receive(:respond_to?).and_call_original
       allow(storage_file).to receive(:respond_to?).with(:name).and_return(true)
       allow(storage_file).to receive(:respond_to?).with(:directory).and_return(true)
       expect(described_class.new(storage_file).call).to eq('file.txt')
     end
  end
end
