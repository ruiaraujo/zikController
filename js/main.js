$(function(){$("a.page-scroll").bind("click",function(a){var b=$(this);$("html, body").stop().animate({scrollTop:$(b.attr("href")).offset().top},1500,"easeInOutExpo"),a.preventDefault()})}),$("body").scrollspy({target:".navbar-fixed-top"}),$(".navbar-collapse ul li a").click(function(){$(".navbar-toggle:visible").click()});