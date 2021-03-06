class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, except: [:show]

  # GET /listings
  # GET /listings.json
  def index
    @listings = Listing.search(params[:term]).includes(:pictures).order(params[:order]).paginate(:page => params[:page], :per_page => 30)
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
    @client = Client.find(params[:client_id]) if params[:client_id]
    authenticate_user! unless @client
    @mortgage_payment = @listing.mortgage_payment_str(@client)
    @total_monthly_cost = @listing.total_monthly_cost_str(@client)
    @cash_flow = @listing.cash_flow_str(@client)
    if @client
      @showing = Showing.find_by(client_id: @client.id, listing_id: @listing.id)
      @notes = @showing.notes
      @note = @showing.notes.new
    elsif current_user 
      @notes = Note.joins(:showing).where('showings.listing_id' => @listing.id)
    end
      
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end
  
  def import
    message = Listing.import(params[:file])
    redirect_to listings_path, message
  end

  # GET /listings/1/edit
  def edit
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)

    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.showings.destroy_all
    @listing.pictures.destroy_all
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:address, :beds, :baths, :parking, :square_footage, :year_built, :listing_date, :asking_price, :parking_price, :condo_fees, :property_tax, :utility_cost, :rent_amount, :lot_size, :description, pictures_attributes: [:id, :url, :caption, :_destroy], showings_attributes: [:id, :client_id, :date, :compare, :_destroy])
    end
end
