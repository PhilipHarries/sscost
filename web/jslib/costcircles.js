

var diameter=Math.min($(window).height(),$(window).width());
var format = d3.format(",d");


var pack = d3.layout.pack()
	.size([diameter,diameter])
	.value(function(d) { 
		return(Math.max(d.cost_pm,1)); 
		});

var svg = d3.select("body")
            .append("div").classed("svg-container", true).append("svg")
            .attr("preserveAspectRatio", "xMinyMin meet")
            .attr("viewBox", "0 0 800 800").append("svg")
            .classed("svg-content-responsive", true); 

d3.json("ss.costcircles.json",function(error,root){
	if(error) throw error;

	var node = svg.datum(root).selectAll(".node").data(pack.nodes)
		.enter().append("g")
		.attr("class", function(d) {
			return d.children ? "node" :"leaf node"; 
			})
		.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });

	node.append("title").text(function(d){return(d.name + "\nmonthly cost: " + '\u00A3' + (d.cost_pm/100)  )});

	node.append("circle").attr("r", function(d){ return d.children ? d.r : (0.7*d.r); });

});

d3.select(self.frameElement).style("height", diameter + "px");
