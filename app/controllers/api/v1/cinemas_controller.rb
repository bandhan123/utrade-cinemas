class Api::V1::CinemasController < ApplicationController


	# def get_cinemas
	# 	h = []
	# 	ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym)
	# 	cinemas = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm")
	# 	now_showing = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm where Film_strNowShowingFlag='Y'")
	# 	up_coming = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm where Film_strUpcomingFlag='Y'")
	# 	feature_movie = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm where Film_strFeatureFlag='Y'")
	# 	ActiveRecord::Base.establish_connection("#{Rails.env}_sec".to_sym)
	# 	all_movie = [];now_show = [];up_array = [];feature_array = []
	# 	cinemas.each do |all_mov|
	# 		all_movie << all_mov
 #    end
	# 	now_showing.each do |now|
	# 		movie = SingleMoviePage.find_by_film_id(now["Film_strCode"])
	# 		now_show << now.merge(triler_image: movie.present? ? movie.title_image.url : '')
	# 	end
	# 	up_coming.each do |up_cm|
	# 		movie = SingleMoviePage.find_by_film_id(up_cm["Film_strCode"])
	# 	  up_array << up_cm.merge(triler_image: movie.present? ? movie.title_image.url : '')
	# 	end
	# 	feature_movie.each do |feature_mv|
	# 	  feature_array << feature_mv
	# 	end
	# 	movie = {}
	# 	movie["all_movies"] = all_movie
	# 	movie["now_shows"] = now_show
	# 	movie["up_coming"] = up_array
 #    movie["feature_hash"] = feature_array
	# 	h << movie
	# 	render json: {data: h, message: "Movies List"}
	# end

	def get_cinemas
		h = {}
		ActiveRecord::Base.establish_connection("#{Rails.env}_sec".to_sym)
		cinemas = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm as film LEFT JOIN SYN_tblFilm as tbl_film on tbl_session.Film_strCode = tbl_film.Film_strCode LEFT JOIN tblCinema as tblCinema on tbl_session.Cinema_strID = tblCinema.Cinema_strID where tblCinema.Cinema_strID = '#{params[:cinema_id]}'")
		now_showing = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm where Film_strNowShowingFlag='Y'")
		up_coming = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm where Film_strUpcomingFlag='Y'")
		feature_movie = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm where Film_strFeatureFlag='Y'")
		h[:all_movies] = cinemas.collect{|all_movie| all_movie}
		h[:now_showing] = now_showing.collect{|now| now}
		h[:up_coming] = up_coming.collect{|up| up}
		h[:feature_movie] = feature_movie.collect{|feature| feature}
		render json: {data: h, message: "Movies List"}
	end

	# def get_movie_info
	# 	single_movie = {}
	# 	ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym)
	# 	movie_info = ActiveRecord::Base.connection.exec_query("SELECT * FROM SYN_tblFilm as film 
	# 		INNER JOIN SYN_tblFilm_Attribute as film_attr on film.Film_strCode = film_attr.Film_strCode
	# 		INNER JOIN SYN_tblPerson as person on person.Film_strCode = film.Film_strCode where film.Film_strCode = '#{params[:film_id]}'")
	#   movie_info_data = movie_info.collect{|mv_info| mv_info}
	#   movie_info_data = movie_info_data.uniq {|h| h[:Film_strCode]}
	#   ActiveRecord::Base.establish_connection("#{Rails.env}_sec".to_sym)
	#   tbl_film = SingleMoviePage.find_by_film_id(params[:film_id])
	#   if tbl_film.present?
	#   	h = {}
	# 	  tbl_movie_img = tbl_film.single_movie_images.map{|img| img.image.url} 
	# 	  tbl_movie_url = tbl_film.single_movie_urls.map{|url| url.url}
	# 	  tbl_movie_star =  tbl_film.single_movie_stars.map{|star|  {name: star.name, url: star.image.url}}
	# 	  h["movie_star"] = tbl_movie_star
	# 	  t_film =  {triler_image: tbl_film.title_image.url, trailer_url: tbl_film.trailer_url, movie_images: tbl_movie_img, movie_url: tbl_movie_url}.merge(h)
	# 	  single_data =  t_film
	# 	  render json: {data: single_data, message: "Single Movie information"}
	# 	else
	# 		render json: {data: [], message: "No Movie information"}
	# 	end
	  
	# end

	def get_movie_shows
		ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym)
	  end_date = params[:datetime].to_time.tomorrow.midnight.strftime("%Y-%m-%d %T.%S")
		movie_show = ActiveRecord::Base.connection.exec_query("select * from SYN_tblSession as tbl_session  
      LEFT JOIN tblCinema as tblCinema on tbl_session.Cinema_strID = tblCinema.Cinema_strID  
      LEFT JOIN SYN_tblPrices as tbl_price on tbl_session.PGroup_strCode = tbl_price.PGroup_strCode   
      LEFT JOIN SYN_tblFilm as tbl_film on tbl_session.Film_strCode = tbl_film.Film_strCode
		  where tbl_session.Film_strCode = '#{params[:film_id]}' AND tbl_session.Session_dtmRealShow BETWEEN '#{params[:datetime]}' AND '#{end_date}'")
		movie_show_data = movie_show.collect{|mv_show| mv_show}
		layout_data = []
		HashWithIndifferentAccess.new(movie_show_data.group_by{|mv| mv["Session_dtmRealShow"]}).each do | val|
			info_data ={}
			info_data["date"] = val[0]
			info_data["uniq_values"] = val[1].map{|v| {Layout_intId: v["Layout_intId"],Session_strStatus: v["Session_strStatus"], Session_strType: v["Session_strType"],PGroup_strCode: v["PGroup_strCode"], Session_intSeatsAvail: v["Session_intSeatsAvail"], Session_intSeatsTotal: v["Session_intSeatsTotal"], Session_strSeatAllocation: v["Session_strSeatAllocation"],TType_strCode: v["TType_strCode"], AreaCat_strCode: v["AreaCat_strCode"],BFee_strCode: v["BFee_strCode"],Price_intSequence: v["Price_intSequence"],Price_strChildTicket: v["Price_strChildTicket"], Price_strPackage: v["Price_strPackage"], Price_strComp: v["Price_strComp"], Price_dtmEffectFrom: v["Price_dtmEffectFrom"], Price_dtmEffectTill: v["Price_dtmEffectTill"], Price_curTax1: v["Price_curTax1"], Price_curTax2: v["Price_curTax2"], Price_curTax3: v["Price_curTax3"], Price_curTax4: v["Price_curTax4"], TType_strHOCode: v["TType_strHOCode"], TType_strDescription: v["TType_strDescription"], Price_curPrice: v["Price_curPrice"]}}
			info_data["cinema_info"] = val[1][0]
			layout_data << info_data
    end
    render json: {data: layout_data, message: "Movie Show Information"}
	end

	def get_movie_avail
		ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym)
		avail_movie = ActiveRecord::Base.connection.exec_query("select * from SYN_tblSession_AreaCount  as area_count INNER JOIN tblCinema as cinema on area_count.Cinema_strID = cinema.Cinema_strId where Session_lngSessionId IN #{params[:session_id]}")
    movie_avail_data = avail_movie.collect{|mv_avl| mv_avl}
    render json: {data: movie_avail_data, message: "Movie Available Information"}
	end

	def get_food_beverage
		ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym)
		fandb = ActiveRecord::Base.connection.exec_query("select * from SYN_tblItems as item  
			LEFT JOIN tblCinema as cinema on cinema.Cinema_strID = item.Cinema_strID 
			LEFT JOIN SYN_tblItem_Packages as package on item.Item_strID = package.Item_strID where item.Cinema_strID = '#{params[:cinema_id]}'")
		fnb_data = fandb.collect{|mv_show| mv_show}
    render json: {data: fnb_data, message: "Food and Bevarage Information"}
	end


	def get_movie_coupons
		ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym)
		coupons = MovieCoupon.order(created_at: :asc)
		if coupons
			mv_coupons = coupons.collect{|cu| {id: cu.id, image: cu.image.url,title: cu.title, description: cu.description, tm_condition: cu.term_condition, el_amount: cu.eligible_amount, coupon: cu.coupon, mx_amount: cu.max_amount, percentage: cu.percentage}}
			render json: {data: mv_coupons, message: "Get all Coupons"}
		else
			render json: {data: [], message: "No Coupons Available"}
		end
	end

end
