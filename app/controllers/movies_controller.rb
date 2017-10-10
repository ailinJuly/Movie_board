class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy, :join, :quit]
  before_action :authenticate_user!,except: [:show,:index,:join, :quit]

  def search
      if params[:search].present?
        @movies = Movie.search(params[:search])
      else
        @movies = Movie.all
      end
    end

    def index
      @movies = Movie.all
    end


  # GET /movies/1
  # GET /movies/1.json
  def show
    @reviews = Review.where(movie_id:@movie.id).order("created_at DESC")
    if @reviews.blank?
      @avg_review = 0
    else
      @avg_review = @reviews.average(:rating).round(2)
    end
  end

  # GET /movies/new
  def new
    @movie = current_user.movies.build
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = current_user.movies.build(movie_params)

    respond_to do |format|
      if @movie.save
        current_user.join!(@movie)
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def join
    if !current_user.is_member_of?(@movie)
      current_user.join!(@movie)
      flash[:notice] = "加入本讨论区成功！"
    else
      flash[:notice] = "您已经是本影片评论员了！"
    end
     redirect_to @movie
  end

  def quit
    if current_user.is_member_of?(@movie)
      current_user.quit!(@movie)
      flash[:notice] = "您已经成功退出本讨论区！"
    else
      flash[:notice] = "您不是本影片评论员，不能退出！"
    end
     redirect_to @movie
  end





  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :description, :movie_length, :director, :rating,:image)
    end
end
