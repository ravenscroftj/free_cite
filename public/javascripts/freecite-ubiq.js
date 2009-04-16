var co;

CmdUtils.CreateCommand({
  _formatCitation: function(citation) {
    html = "<b><u>Citation</u></b><br>";
    for (p in citation) {
      d = citation[p];
      if (d && p != "id" && p != "raw_string" && p != "contexts") {
        html += "<i>" + p + "</i>: " + d + "<br><br>";
      }
    }
    co = html;
    return html;
  },

  _getParsedCitation: function(text, pblock) {
    var url = "http://freecite.library.brown.edu/citations/create";
    var me = this;
    var params = {
      citation: text
    };
    jQuery.ajax({
      type: "POST",
      url: url,
      data: params,
      dataType: "json",
      error: function() {
        pblock.innerHTML = "Error";
        displayMessage("FreeCite error");
      },
      success: function(result, status) {
        html = me._formatCitation(result[0]);
        //displayMessage("FreeCite success result.raw: " + html);
        if (pblock) {
          pblock.innerHTML = html + "<b><u>Raw Text</u></b><br><span>" + text +
            "</span><br>";
        }
      }
    });

  },

  name: "freecite",
  icon: "http://example.com/example.png",
  homepage: "http://freecite.library.brown.edu/",
  author: { name: "Chris Shoemaker", email: "chris.shoemaker@pubdisplay.com"},
  license: "GPL",
  description: "Parses plain-text bibliographic citations",
  help: "Just select the citation.",
  takes: {"input": noun_arb_text},
  preview: function( pblock, input ) {
    pblock.innerHTML = "parsing...";
    this._getParsedCitation(input.text, pblock);
  },
  execute: function(input) {
    CmdUtils.setSelection(co);
    //CmdUtils.setSelection("You selected: " + input.html);
  }
});