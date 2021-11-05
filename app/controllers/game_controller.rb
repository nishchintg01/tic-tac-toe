class GameController < ApplicationController
    self.per_form_csrf_tokens = true
    before_action :save_details, only: %i[start]

    # Root Page of the Application
    def index
        session[:scores] = ["","","","","","","","",""]
    end

    # Contains Game Layout and Player Details 
    def start
        puts session[:player1]
        logger.info("New Game Started")
    end

    # Returns Game Details in Json Format
    def stats
        puts params
        session[:status] = "running"
        idx =  params[:box]
        if session[:scores][idx.to_i] == ""
            session[:scores][idx.to_i] = params[:choice]
        end
        session[:current_player] = params[:id].to_i
        print session[:scores]
        puts()
        logger.info("Player #{params[:id]} Has played move #{params[:box]}")
        respond_to do |format|
            if check_result(session[:scores])
                logger.info("player #{params[:id]} won the game")
                puts "player #{params[:id]} won the game"
                msg = {:id => params[:id], :success => "ok", :scores => session[:scores], :result => "win", :turns => count_turns }
                format.json { render json: msg, status: :ok }
            else
                msg = {:id => params[:id], :success => "ok", :scores => session[:scores], :result => "", :turns => count_turns}
                output = { status: 200, message: 'OK' }
                format.json { render json: msg, status: :ok }
            end
        end    
    end

    # Resets the Sessions and redirects to the home page after successfull execution
    def restart
        session[:status] = ""
        session[:current_player] = ""
        session[:scores] = ["","","","","","","","",""]
        session[:player1] = nil
        session[:player2] = nil
        session[:choice1] = nil
        session[:choice2] = nil
        redirect_to :action => "index"
    end

    private

    # Creates sessions for players and their choices 
    def save_details
        begin 
            if session[:player1].nil? && session[:player2].nil? && session[:choice1].nil? && session[:choice2].nil?
                session[:player1] = params[:player1].chomp
                session[:player2] = params[:player2].chomp
                session[:choice1] = params[:choice1].chomp
                session[:choice2] = params[:choice2].chomp
            end
        rescue Exception => exc 
            redirect_to :action => "index"
        end
    end

=begin
score = [
    [0,1,2]
    [3,4,5]
    [6,7,8]
]
 conditios to win =[
     [0,1,2]
     [3,4,5]
     [6,7,8]
     [0,4,8]
     [2,4,6]
     [0,3,6]
     [1,4,7]
     [2,5,8]
 ]        
=end

    # Checks for the Winning condition Mentioned Above
    def check_result(scores)
        if (check_condition(scores, 0, 1, 2) || check_condition(scores, 3, 4, 5) || check_condition(scores, 6, 7, 8) ||
            check_condition(scores, 0, 3, 6) || check_condition(scores, 1, 4, 7) || check_condition(scores, 2, 5, 8) ||
            check_condition(scores, 0, 4, 8) || check_condition(scores, 2, 4, 6))
            return true
        end
        return false
    end

    # Function for code resueability and for checking winning conditions
    def check_condition(scores, id1, id2, id3)
        if(scores[id1] != "" && scores[id2] != "" && scores[id3] != "" && scores[id1] == scores[id2] && scores[id2] == scores[id3])
            return true
        end
        return false
    end

    # Counts how many boxes have been marked
    def count_turns
        session[:turns] = 0
        for score in session[:scores].each
            if score != ""
                session[:turns] += 1
            end
        end
        return session[:turns]
    end
end
