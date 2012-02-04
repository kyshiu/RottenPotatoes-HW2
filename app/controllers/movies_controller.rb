class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = ['G','PG','PG-13','R']
    @ratings = []
    @checked = {}
    if params.has_key?(:ratings)
      @ratings = params[:ratings].keys
      @checked = params[:ratings]
    end
    if params.has_key?(:sort_title)
      @movies = Movie.find(:all, :order=>"title ASC",:conditions => {:rating=>@ratings})
      @title_head_class = "hilite"
      @release_head_class = nil
    elsif params.has_key?(:sort_release_date)
      @movies = Movie.find(:all, :order=>"release_date ASC",:conditions => {:rating=>@ratings})
      @title_head_class = nil
      @release_head_class = "hilite"
    else
      @movies = Movie.find(:all, :conditions => {:rating=>@ratings})
      @title_head_class = nil
      @release_head_class = nil
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
