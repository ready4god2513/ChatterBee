Jegit.controllers :static do
  
  get "/stylesheets/:style.css" do |style|
    scss style.to_sym
  end
  
  get :privacy do
    erb "static/privacy".to_sym
  end
  
end