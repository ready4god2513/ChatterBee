class Jegit
  
  get "/:style.css" do |style|
    scss style.to_sym
  end
  
  get "/privacy" do
    erb :privacy
  end
  
end