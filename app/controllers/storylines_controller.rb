require 'tactful_tokenizer'
require 'amatch'

class StorylinesController < ApplicationController
  # GET /storylines
  # GET /storylines.json
  def index
    @storylines = Storyline.roots
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @storylines }
    end
  end

  # GET /storylines/1
  # GET /storylines/1.json
  def show
    @storyline = Storyline.find(params[:id])    
    other_ids = params[:other_ids] ? params[:other_ids].split(",").map{|x| x.to_i} : []
    @continuations = @storyline.random_continuation(other_ids, [params[:next].to_i])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @storyline }
      format.js { @continuations.unshift @storyline }
    end
  end

  # GET /storylines/new
  # GET /storylines/new.json
  def new
    @storyline = Storyline.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @storyline }
    end
  end

  # GET /storylines/1/new_continue
  def new_continue
    @storyline_next = Storyline.new
    @storyline_next.prev = params[:storyline_id]
    @start_id = params[:start_id]
    
    respond_to do |format|
      format.js
    end
  end
  
  # GET /storylines/1/upvote
  def upvote
    @storyline = Storyline.find(params[:storyline_id])
    if @current_user
      like = Like.new
      like.user = @current_user
      like.storyline = @storyline
      if like.valid?
        @storyline.upvote
        like.save
      end
    end
    
    respond_to do |format|
      format.js
    end
  end

  # GET /storylines/1/edit
  def edit
    @storyline = Storyline.find(params[:id])
    @storyline.prev = params[:prev]
    @storyline.next = params[:next]
    @start_id = params[:start_id]
    
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /storylines
  # POST /storylines.json
  def create
    @storyline = Storyline.new(params[:storyline])
    @start_id = params[:start_id]
    
    # Split into sentences and create separate storylines for each sentence
    lines = TactfulTokenizer::Model.new.tokenize_text(@storyline.line)   
    previous = Storyline.find(@storyline.prev) if @storyline.prev
    lines.each do |line|
      @storyline = Storyline.new(:line => line)
      @storyline.user = @current_user if @current_user
      @storyline.save
      if previous
        @storyline.insert_after(previous, true)
      else
        @storyline.root = true
        @storyline.save
      end
      previous = @storyline
      @first_line ||= @storyline
    end
    
    respond_to do |format|
      if @storyline.save
        format.js
        format.html { redirect_to @first_line, notice: 'Storyline was successfully created.' }
        format.json { render json: @storyline, status: :created, location: @storyline }
      else
        format.html { render action: "new" }
        format.json { render json: @storyline.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /storylines/1
  # PUT /storylines/1.json
  def update
    @storyline = Storyline.find(params[:id])
    @rest_ids = @storyline.id.to_s
    @start_id = params[:start_id]
    prev_id = params[:storyline][:prev]
    next_id = params[:storyline][:next]
    
    puts prev_id
    puts next_id
    puts params.inspect
    
    # Decide if user can edit the current line - only happens if no user owns the line or belongs to the current user
    # Else, one can only create new lines
    user_can_edit = (@storyline.user == nil || @storyline.user == @current_user)
    
    lines = TactfulTokenizer::Model.new.tokenize_text(params[:storyline][:line])
    
    # Perform a simple update if still only 1 sentence, and edit distance is small
    if lines.size == 1 and user_can_edit and Amatch::PairDistance.new(@storyline.line).match(lines[0]) > 0.8
      @storyline.update_attributes(params[:storyline])
    else
      @rest_ids = ""
      prev_line = Storyline.exists?(prev_id) ? Storyline.find(prev_id) : nil
      next_line = Storyline.exists?(next_id) ? Storyline.find(next_id) : nil
      # If first line matches, update it, then insert new path after that
      # Elif last line matches, update it, then insert new path before that
      ol = Amatch::PairDistance.new(@storyline.line)
      if user_can_edit
        if ol.match(lines[0]) > 0.8
          @storyline.update_attribute :line, lines.shift
          prev_line = @storyline
          @rest_ids = @storyline.id.to_s + ","
        elsif ol.match(lines[-1]) > 0.8
          @storyline.update_attribute :line, lines.pop
          next_line = @storyline
        end
      end
      
      if lines.size >= 1
        ## @storyline.update_attribute :line, lines.shift
        @storyline = Storyline.new(:line => lines.shift)
        @storyline.user = @current_user if @current_user
        @storyline.save
        @storyline.insert_between(prev_line, next_line, true)
        prev_line = @storyline
        @rest_ids += @storyline.id.to_s
        lines.each do |line|
          @storyline = Storyline.new(:line => line)
          @storyline.user = @current_user if @current_user
          @storyline.save
          @storyline.insert_between(prev_line, next_line)
          prev_line = @storyline
        end            
      end
    end
        
    respond_to do |format|
      format.html { redirect_to @storyline, notice: 'Storyline was successfully updated.' }
      format.json { head :no_content }
      format.js
    end
    # respond_to do |format|
    #   if @storyline.update_attributes(params[:storyline])
    #     format.html { redirect_to @storyline, notice: 'Storyline was successfully updated.' }
    #     format.json { head :no_content }
    #   else
    #     format.html { render action: "edit" }
    #     format.json { render json: @storyline.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /storylines/1
  # DELETE /storylines/1.json
  def destroy
    @storyline = Storyline.find(params[:id])
    @storyline.destroy

    respond_to do |format|
      format.html { redirect_to storylines_url }
      format.json { head :no_content }
    end
  end
end
