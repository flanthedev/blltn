class BoardsController < ApplicationController
  before_action :logged_in_user,        only: [:new, :create, :edit, :update, :destroy]
  before_action :admin_membership,      only: [:edit, :update, :destroy]

  def index
    @boards = Board.all
    respond_to do |format|
      format.js { render partial: 'boards/index.js' }
    end
  end

  def new
    respond_to do |format|
      format.js { render partial: 'boards/new.js' }
    end
  end

  def show
    @board = Board.find(params[:id])
    @post = Post.new
    @posts = @board.posts.today

    if logged_in? && @board.users.include?(current_user)
      @membership = Membership.find_by(board_id: params[:id],
                                       user_id: current_user.id)
    else
      @membership = Membership.new
    end

    respond_to do |format|
      format.js { render partial: 'boards/show' }
    end

  end

  def create
   @board = Board.new(board_params)
   if @board.save
      create_admin(current_user)
      flash[:success] = "board created"
      redirect_to @board
   else
      puts @board.errors.full_messages
      render :new
   end
  end

  def edit
    respond_to do |format|
      format.js { render partial: 'boards/edit.js' }
    end
  end

  def update
    if @board.update_attributes(board_params)
      respond_to do |format|
        format.js { render partial: 'boards/update.js' }
      end
    end
  end

  def destroy
    @board.destroy if !@board.nil?
    flash[:success] = "board deleted"
    redirect_to root_url
  end

  private

    def board_params
      params.require(:board).permit(:name, :info)
    end

    # make current_user an admin when creating a board
    def create_admin(user)
      Membership.create(board_id: @board.id, user_id: user.id, admin: true)
    end

    def current_membership
      @current_membership = Membership.find_by(board_id: params[:id].to_i, user_id: current_user.id)
    end

    def admin_membership
      @board = Board.find(params[:id])

      if logged_in? && @board.users.include?(current_user)
        @membership = Membership.find_by(board_id: params[:id],
                                         user_id: current_user.id)
      else
        @membership = Membership.new
      end

      redirect_to(root_url) unless @membership.admin?
    end

 end
