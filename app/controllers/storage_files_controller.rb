class StorageFilesController < ApplicationController
  before_action :set_directory
  before_action :set_storage_file, only: [ :show, :edit, :update, :destroy ]

  def index
    @directory = Directory.find(params[:directory_id])
    @storage_files = @directory.storage_files
  end

  def show
  end

  def new
    @storage_file = @directory.storage_files.build
  end

  def edit
  end
  def create
    @storage_file = @directory.storage_files.build(storage_file_params)
    if @storage_file.save
      redirect_to [ @directory, @storage_file ], notice: "Arquivo criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def update
    if @storage_file.update(storage_file_params)
      redirect_to [ @directory, @storage_file ], notice: "Arquivo atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @storage_file.destroy
    redirect_to directory_storage_files_path(@directory), notice: "Arquivo removido."
  end

  def download
   @directory = Directory.find(params[:directory_id])
   @storage_file = @directory.storage_files.find(params[:id])

    if @storage_file.blob?
      send_data @storage_file.blob_data, filename: @storage_file.name, disposition: :attachment
    elsif @storage_file.file.attached?
      redirect_to rails_blob_url(@storage_file.file, disposition: "attachment")
    else
      redirect_to [ @directory, @storage_file ], alert: "Arquivo não disponível para download."
    end
  end

  private

  def set_directory
    @directory = Directory.find(params[:directory_id])
  end

  def set_storage_file
    @storage_file = @directory.storage_files.find(params[:id])
  end

  def storage_file_params
    params.require(:storage_file).permit(:name, :file, :file_type_storage)
  end
end
