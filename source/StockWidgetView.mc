using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Communications;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

class StockWidgetView extends WatchUi.View {

	var symbol = Application.getApp().getProperty("symbol");
	var latestPrice = 0.0;
	var change = 0.0;
	var changePercent = 0.0;
	var requestStarted = false;
	
	function storeInfo(id, sym, price, change, percent) {
		Storage.setValue("symbol" + id, sym); 
		Storage.setValue("price" + id, price); 
		Storage.setValue("change" + id, change); 
		Storage.setValue("percent" + id, percent); 
	}
	
	function getSymbol(id) {
		return Storage.getValue("symbol" + id);
	}
	
	function getPrice(id) {
		return Storage.getValue("price" + id);
	}
	
	function getChange(id) {
		return Storage.getValue("change" + id);
	}
	
	function getPercent(id) {
		return Storage.getValue("percent" + id);
	}
	
	// set up the response callback function
	function onReceive(responseCode, data) {
		if (responseCode == 200) {
		System.println("Request Successful");                   // print success
		latestPrice = data["latestPrice"];
		change = data["change"];
		changePercent = data["changePercent"] * 100;
		symbol = data["symbol"];
		storeInfo(1, symbol, latestPrice, change, changePercent);	
        System.println("latestPrice: "+ latestPrice.format("%.2f"));
        System.println("change: "+ change.format("%.2f"));
        System.println("changePercent: "+ changePercent.format("%.2f"));
        
        WatchUi.requestUpdate();
       }
       else {
           System.println("Response: " + responseCode);            // print response code
       }
	   requestStarted = false;
   }

   function makeRequest(sym) {
   	   if (requestStarted) {
   	   		return;
   	   } 
   	   requestStarted = true;
       var url = "https://cloud.iexapis.com/stable/stock/" + sym + "/quote";                         // set the url

       var params = {                                              // set the parameters
              "token" => "pk_0b1edd892668490f97c2fa8d622e944f"
       };

       var options = {                                             // set the options
           :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
           :headers => {                                           // set headers
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
       };

       var responseCallback = method(:onReceive);                  // set responseCallback to
                                                                   // onReceive() method
       // Make the Communications.makeWebRequest() call
       Communications.makeWebRequest(url, params, options, method(:onReceive));
  	}
  
	function initialize() {
		System.println("initialize");
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	System.println("onLayout");
        setLayout(Rez.Layouts.MainLayout(dc));
        findDrawableById("id_symbol").setText(symbol);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        System.println("onShow");
        var sym = Application.Properties.getValue("symbol");
    	makeRequest(sym);
        System.println("onShow - after makeRequest");
    }

    // Update the view
    function onUpdate(dc) {
        System.println("onUpdate");

    	latestPrice = getPrice(1);
    	symbol = getSymbol(1);
    	change = getChange(1);
    	changePercent = getPercent(1);
    	
    	//trigger a web request in case symbol has changed
    	var setSymbol = Application.Properties.getValue("symbol");
    	System.println("setSymbol: " + setSymbol + ", saved symbol: " + symbol);
    	if (!setSymbol.equals(symbol)) {
    		makeRequest(setSymbol);
    	}
    	findDrawableById("id_updating").setText(requestStarted ? "Updating..." : "");
        findDrawableById("id_price").setText(latestPrice != null ? latestPrice.format("%.2f") : "---");
        findDrawableById("id_symbol").setText(symbol != null ? symbol : "Needs phone");
        
        var changeDraw = findDrawableById("id_change");
        var percentDraw = findDrawableById("id_percent");

        changeDraw.setText(change != null ? change.format("%.2f") + "  " : "---");
        percentDraw.setText(changePercent != null ? "(" + changePercent.format("%.2f") + "%)" : "(---)");
        if ((change != null) && (change < 0)) {
        	changeDraw.setColor(Graphics.COLOR_RED);
        	percentDraw.setColor(Graphics.COLOR_RED);
        } else {
        	changeDraw.setColor(Graphics.COLOR_GREEN);
        	percentDraw.setColor(Graphics.COLOR_GREEN);
        }
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
