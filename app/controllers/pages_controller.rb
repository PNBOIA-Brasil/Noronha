class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def admin
    @systems = System.all
  end

  def home
    if params[:commit]
      start_date = params[:start_date]
      end_date = params[:end_date]
      start_date = Date.parse start_date
      end_date = Date.parse end_date
    else
        start_date = (Time.now - 5.day)
        end_date = (Time.now + 1.day)
    end
    if start_date < (Time.now - 5.day)
      start_date = (Time.now - 5.day)
    end
    if end_date < start_date
      end_date = Time.now + 1.day
    end

    @almirantado_int = System.where("name ='almirantado_int' ") [0]
    @almirantado_ext = System.where("name ='almirantado_ext' ") [0]
    @station = System.where("name ='station' ") [0]
    @inpe = System.where("name ='inpe' ") [0]

    @almirantado_int_data = get_remobs(@almirantado_int, start_date, end_date)
    @almirantado_ext_data = get_remobs(@almirantado_ext, start_date, end_date)
    @station_data = get_remobs(@station, start_date, end_date)
    @inpe_data = get_remobs(@inpe, start_date, end_date)

    @systems = [@almirantado_int, @almirantado_ext, @station, @inpe]
		raise
  end

  private

  def get_remobs(buoy, start_date, end_date)

  response = RestClient.get("http://143.198.233.67/api/v1/data_buoys?buoy=#{buoy.buoy_id.to_i}&start_date=#{start_date.strftime("%Y-%m-%d")}&end_date=#{end_date.strftime("%Y-%m-%d")}&token=#{ENV["REMOBS_TOKEN"]}")

  remobs_response = JSON.parse(response)

  params = {}
  params[:swvht] = []
  params[:mxwvht] = []
  params[:tp] = []
  params[:sst] = []
  params[:wvspread] = []
  params[:wvdir] = []
  params[:date_time] = []
  params[:buoy_id] = []
  params[:wspd] = []
  params[:wdir] = []
  params[:gust] = []
  params[:wvdirg] = []
  params[:wdirg] = []

  remobs_response.each do |item|
    params[:buoy_id] << item['buoy_id']

    if item['flag_swvht'].to_i > 0
      params[:swvht] << nil
    else
      params[:swvht] << item['swvht1'].to_f
    end

    if item['flag_mxwvht'].to_i > 0
      params[:mxwwvht] << nil
    else
      params[:mxwvht] << item['mxwvht1'].to_f
    end

    if item['flag_tp'].to_i > 0
      params[:tp] << nil
    else
      params[:tp] << item['tp1'].to_f
    end

    if item['flag_sst'].to_i > 0
      params[:sst] << nil
    else
      params[:sst] << item['sst'].to_f
    end

    if item['flag_wvspread'].to_i > 0
      params[:wvspread] << nil
    else
      params[:wvspread] << item['wvspread1'].to_f
    end

    params[:date_time] << Time.parse(item['date_time'])

    if item['flag_wdir'].to_i > 0
      params[:wdir] << nil
    else
      params[:wdir] << item['wdir'].to_i
    end

    if item['flag_wdir'].to_i > 0
      params[:wdirg] << nil
    else
      params[:wdirg] << (item['wdir'].to_i/10)*10
    end

    if item['flag_gust'].to_i > 0
      params[:gust] << nil
    else
      params[:gust] << item['gust'].to_f
    end

    if item['flag_wspd'].to_i > 0
      params[:wspd] << nil
    else
      params[:wspd] << item['wspd'].to_f
    end

    if item['flag_wvdir'].to_i > 0
      params[:wvdir] << nil
    else
      params[:wvdir] << item['wvdir1'].to_f
    end

    if item['flag_wvdir'].to_i > 0
      params[:wvdirg] << nil
    else
      params[:wvdirg] << (item['wvdir1'].to_i/10)*10
    end
  end
  return params
end
end
