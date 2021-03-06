class PostsController < ApplicationController
  before_action :logged_in_user,  only: [:create, :destroy]
  before_action :correct_user,    only: [:destroy]
  before_action :user_is_member,  only: [:create]

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      respond_to do |format|
        format.js { render partial: 'posts/create.js' }
      end
    # else
    #   flash[:danger] = "post not created"
    #   redirect_to @board
    end

  end

  def destroy
    @post.destroy unless @post.nil?
    respond_to do |format|
      format.js { render partial: 'posts/destroy.js' }
    end

  end

  def edit
    @post = Post.find(params[:id])
    if @post.save
      respond_to do |format|
        format.js { render partial: 'posts/edit.js', post: @post }
      end
    end
  end

  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(post_params)
      respond_to do |format|
        format.js { render partial: 'posts/update.js', post: @post }
      end
    end
  end

  private

    def post_params
      params.require(:post).permit(:content, :board_id)
    end

    def correct_user
      @post = current_user.posts.find_by(id: params[:id])
      redirect_to root_url if @post.nil?
    end

    def user_is_member
      # @membership = current_user.memberships.find_by(board_id: params[:post][:board_id])

      # if @membership.nil?
      #   @board = Board.find_by(id: params[:post][:board_id])
      #   redirect_to @board
      #   flash[:danger] = "please join board to post"
      # else
      #   @board = @membership.board
      # end
    end

end
