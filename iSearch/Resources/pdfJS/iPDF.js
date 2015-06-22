(function() {
  window.iPDF = {
     renderPDF: function(pdfPath) { 
      //
      // Fetch the PDF document from the URL using promises
      //
      PDFJS.getDocument(pdfPath).then(function(pdf) {
        console.log("pdf page num: " + pdf.numPages);
        // Using promise to fetch the page
        pdf.getPage(1).then(function(page) {

          var w = window,
              d = document,
              e = d.documentElement,
              g = d.getElementsByTagName('body')[0],
              x = w.innerWidth || e.clientWidth || g.clientWidth,
              y = w.innerHeight|| e.clientHeight;//|| g.clientHeight;

          var desiredWidth = x;
          var viewport = page.getViewport(1);
          var scale = desiredWidth / viewport.width;

          console.log("height: " + y + " width: " + x);
          console.log("scale: " + scale);

          var viewport = page.getViewport(scale);
          //
          // Prepare canvas using PDF page dimensions
          //
          var canvas = document.getElementById('the-pdf-canvas');
          var context = canvas.getContext('2d');
          canvas.height = viewport.height;
          canvas.width = viewport.width;

          //
          // Render PDF page into canvas context
          //
          var renderContext = {
            canvasContext: context,
            viewport: viewport
          };
          page.render(renderContext);
        });
      });
    }
  }

}).call(this);