class ProjectsController < ApplicationController
    # before_action :authenticate_user!

    def index
      projects = Project.all
      render json: projects, status: :ok
    end

    def show
      project = Project.find(params[:id])

      render json: project, status: :ok
    end

    def create
      project = current_user.project.new(project_params)
      project.save

      render_errors(project.errors.full_messages) && return if project.errors.any?

      render json: project, status: :created
    end

    def update
      project = Project.find(params[:id])

      project.update_attributes(project_params)

     
      render json: project, status: :ok
    end

    def destroy
      project = Project.find(params[:id])
      
      render_errors('Could not delete project') && return unless project.destroy

      render json: project, status: :ok
    end

    def zillow_flow
    	project = Project.create(project_params)
    	puts project.inspect
    	old_projects = Project.all.first(10)
    	closest_distance_project = ['', '']

    	#getting location information from zilloq
    	require "open-uri"
			data = URI.parse("https://www.zillow.com/webservice/GetDeepSearchResults.htm?zws-id=X1-ZWz17jcynzxx57_14qhc&address=#{project.address}&citystatezip=#{project.city} #{project.state} #{project.zip}").read
    	xml_doc = Nokogiri::XML(data)
    	if xml_doc.at('code').text == '0'
	    	zestimate = xml_doc.at('amount').text
	    	coordinates = [xml_doc.at('latitude').text, xml_doc.at('longitude').text]
	    	year_built = xml_doc.at('yearBuilt').text
	    	sqfoot = xml_doc.at('finishedSqFt').text

	    	#getting closest project from old projects
	    	if project.type_of_project == "gut" or project.type_of_project == "full"
	    		old_projects.each do |old_project|
	    			if old_project.type_of_project == "gut" or project.type_of_project == "full"
	    				old_data = URI.parse("https://www.zillow.com/webservice/GetSearchResults.htm?zws-id=X1-ZWz17jcynzxx57_14qhc&address=#{old_project.address}&citystatezip=#{old_project.city} #{old_project.state} #{old_project.zip}").read
				    	old_xml_doc = Nokogiri::XML(data)
				    	old_project_coordinates = [old_xml_doc.at('latitude').text, old_xml_doc.at('longitude').text]
	    				old_project_coordinates = Geocoder.search("#{old_project.address}, #{old_project.city} #{old_project.zip}").first.coordinates unless old_project_coordinates
	    				puts "#{old_project.address}, #{old_project.city} #{old_project.zip}"
	    				distance = Geocoder::Calculations.distance_between(coordinates, old_project_coordinates)
	    				closest_distance_project = [distance, old_project.id] if closest_distance_project.all?(&:blank?) or distance < closest_distance_project[0]
	    			end	
	    		end	

	    	elsif project.type_of_project == "kitchen"
	    		old_projects.each do |old_project|
	    			if old_project.type_of_project == "kitchen"
	    				old_data = URI.parse("https://www.zillow.com/webservice/GetSearchResults.htm?zws-id=X1-ZWz17jcynzxx57_14qhc&address=#{old_project.address}&citystatezip=#{old_project.city} #{old_project.state} #{old_project.zip}").read
				    	old_xml_doc = Nokogiri::XML(data)
				    	old_project_coordinates = [old_xml_doc.at('latitude').text, old_xml_doc.at('longitude').text]
	    				old_project_coordinates = Geocoder.search("#{old_project.address}, #{old_project.city} #{old_project.zip}").first.coordinates unless old_project_coordinates
	    				puts "#{old_project.address}, #{old_project.city} #{old_project.zip}"
	    				distance = Geocoder::Calculations.distance_between(coordinates, old_project_coordinates)
	    				closest_distance_project = [distance, old_project.id] if closest_distance_project.all?(&:blank?) or distance < closest_distance_project[0]
	    			end	
	    		end	
	    	else
	    		ProjectMailer.other_type_project(project.user, project).deliver_now
	    	end	

	    	unless project.type_of_project == "other" 	
		    	#calculating estimation
		    	closest_project = Project.find(closest_distance_project[1])
		    	
		    	if closest_distance_project[0] < 2
		    		if zestimate.to_i < 1000000
		    			ProjectMailer.less_estimate(project.user, project).deliver_now
		    		else
		    			if (closest_project.year_built.to_i - year_built.to_i) <10
		    				final_estimation = sqfoot * closest_project.val_sf
		    				msg = ''
		    				ProjectMailer.estimate_email(project.user, project, final_estimation.to_i, msg).deliver_now
		    			else
		    				msg = 'Your house is within 2 miles of one of our old project, but it is a few years old, so we will contact you after review.'
		    				ProjectMailer.old_house_estimate(project.user, project, msg).deliver_now
		    			end	
		    		end						
		    	elsif closest_distance_project[0] <5
		    		if zestimate.to_i < 1000000
		    			ProjectMailer.less_estimate(project.user, project).deliver_now
		    		else
		    			if (closest_project.year_built.to_i - year_built.to_i) <10
		    				final_estimation = sqfoot * closest_project.val_sf
		    				msg = 'We found similar project a bit out of your neighbourhood, so values may very widely.'
		    				ProjectMailer.estimate_email(project.user, project, final_estimation.to_i, msg).deliver_now
		    			else
		    				msg = 'Your house is within 5 miles of one of our old project, but it is a few years old, so we will contact you after review.'
		    				ProjectMailer.old_house_estimate(project.user, project, msg).deliver_now
		    			end	
		    		end
		    	elsif closest_distance_project[0] > 5
		    		if zestimate.to_i < 1000000
		    			ProjectMailer.less_estimate(project.user, project).deliver_now
		    		else
		    			if (closest_project.year_built.to_i - year_built.to_i) <10
		    				final_estimation = sqfoot * closest_project.val_sf
		    				msg = 'Your house is in a new neighbourhood for house, We would be happy to come check out your project free of charge.'
		    				ProjectMailer.estimate_email(project.user, project, final_estimation.to_i, msg).deliver_now
		    			else
		    				msg = 'Your house is more than 5 miles far fromone of our old project, but that project is a few years old, so we will contact you after review.'
		    				ProjectMailer.old_house_estimate(project.user, project, msg).deliver_now
		    			end	
		    		end
		    	end
		    end
		  else
		  	ProjectMailer.wrong_donation_data(project, project.user.email).deliver_now
	    end	

    	render json: { message: "Please check your email for response. Thankyou !"}, status: :ok
    end	

    private

    def project_params
      params.require(:project).permit(:type_of_project, :address, :city, :state, :zip, :year_built, :user_id)
    end
end