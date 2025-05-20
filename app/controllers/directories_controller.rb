class DirectoriesController < ApplicationController
  before_action :set_directory, only: %i[show edit update destroy new_subdirectory]

  def index
    @directories = Directory.where(parent_id: nil)
  end

  def show; end

  def new
    @directory = Directory.new
  end

  def edit; end
  def create
    @directory = Directory.new(directory_params)

    if @directory.save
      redirect_to @directory, notice: "Diretório criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def update
    if @directory.update(directory_params)
      redirect_to @directory, notice: "Diretório atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @directory.destroy
    redirect_to directories_path, notice: "Diretório removido."
  end

  def new_subdirectory
    @subdirectory = @directory.subdirectories.build
    render :new
  end

  private

  def set_directory
    @directory = Directory.find(params[:id])
  end

  def directory_params
    params.require(:directory).permit(:name, :parent_id)
  end
end
