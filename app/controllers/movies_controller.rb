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
    @sort_title = false
    @sort_release = false

    if params.has_key?("commit") and (params["commit"] == "Refresh")
      session[:ratings] = params[:ratings]
      if session[:ratings] == nil
        session[:ratings] = {}
      end
    end
    if params.has_key?(:ratings)
      session[:ratings] = {} unless session.has_key?(:ratings)
      more_keys = false
      extra_keys = []
      params[:ratings].each_key do |rating|
        if not session[:ratings].has_key?(rating)
          more_keys = true
          extra_keys << rating
        end
      end
      if more_keys
        extra_keys.each do |rating|
          session[:ratings][rating] = 1
        end
      end
    end
    if params.has_key?(:sort_title) and not params.has_key?(:sort_release_date)
      session[:sort_title] = params[:sort_title]
      if session.has_key?(:sort_release_date)
        session.delete(:sort_release_date)
      end
    end
    if params.has_key?(:sort_release_date) and not params.has_key?(:sort_title)
      session[:sort_release_date] = params[:sort_release_date]
      if session.has_key?(:sort_title)
        session.delete(:sort_title)
      end
    end
    if params.has_key?(:sort_title) and params.has_key?(:sort_release_date)
      session[:sort_title] = params[:sort_title]
      session[:sort_release_date] = params[:sort_release_date]
    end
    puts "**SESSION AFTER UPDATE**"
    puts session
    puts "**PARAMS**"
    puts params

    more_keys = false
    extra_keys = []
    if params.has_key?(:ratings)
      session[:ratings].each_key do |rating|
        if not params[:ratings].has_key?(rating)
          more_keys = true
          extra_keys << rating
        end
      end
    else
      params[:ratings] = session[:ratings]
    end
    if more_keys
      extra_keys.each do |rating|
        params[:ratings][rating] = 1
      end
    end

    more_sort = false
    if not (params.has_key?(:sort_title) or params.has_key?(:sort_release_date))
      if session.has_key?(:sort_title)
        params[:sort_title] = session[:sort_title]
        more_sort = true
      end
      if session.has_key?(:sort_release_date)
        params[:sort_release_date] = session[:sort_release_date]
        more_sort = true
      end
    end

    if more_keys or more_sort
      puts more_keys
      puts more_sort
      redirect_to movies_path(params)
    end

    if params.has_key?(:ratings)
      @ratings = params[:ratings].keys
      @checked = params[:ratings]
    end
    if (params.has_key?(:sort_title) and (params[:sort_title]=="true"))
      @movies = Movie.find(:all, :order=>"title ASC",:conditions => {:rating=>@ratings})
      @title_head_class = "hilite"
      @release_head_class = nil
      @sort_title = true
      @sort_release = false
    elsif ((params.has_key?(:sort_release_date)) and (params[:sort_release_date]=="true"))
      @movies = Movie.find(:all, :order=>"release_date ASC",:conditions => {:rating=>@ratings})
      @title_head_class = nil
      @release_head_class = "hilite"
      @sort_title = false
      @sort_release = true
    else
      @movies = Movie.find(:all, :conditions => {:rating=>@ratings})
      @title_head_class = nil
      @release_head_class = nil
      @sort_title = false
      @sort_release = false
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
