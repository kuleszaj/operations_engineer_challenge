$(document).ready(function() {
  window.isEmpty = function(str) {
    return (!str || 0 === str.length || /^\s+$/.test(str));
  };

  window.isValidUrl = function(str) {
    return /^(http|https):\/\/[^ "]+$/.test(str);
  }

  window.isValidTag = function(str) {
    return /^[A-Za-z0-9]{1,16}$/.test(str);
  }

  function drawTable(data) {
    var thead = $("<thead>");
    var tbody = $("<tbody>");
    var row = $("<tr>");
    $("#list").append(thead);
    thead.append(row);
    row.append($("<th>Short URL</th>"));
    row.append($("<th>Long URL</th>"));
    row.append($("<th>Date Modified</th>"));
    row.append($("<th>Delete</th>"));
    $("#list").append(tbody);
    for (var i = 0; i < data.length; i++) {
        drawRow(data[i]);
    }
    initializeDataTables();
  }

  function drawRow(rowData) {
    var row = $("<tr>");
    $("#list tbody").append(row);
    row.append($("<td class='tag'><a class='tag' href='http://" +
                 window.location.host + "/" + rowData.tag + "'>http://" +
                 window.location.host + "/" + rowData.tag + "</a></td>"));
    row.append($("<td class='url'><a class='url' href='" + rowData.url + "'>" +
                 rowData.url + "</a></td>"));
    row.append($("<td class='date'>" + new Date(rowData.created_at) + "</td>"));
    row.append($("<td class='delete'><input type='button' class='delete' " +
                 "id='delete_" + rowData.tag + "' /></td>"));
  }

  function updateTable() {
    $.ajax({url: '/mappings', complete: function (XMLHttpRequest, textStatus) {
      $("#list_wrapper").remove();
      $(".mapping_listing").append("<table class='display' id='list'></table>");
      drawTable(JSON.parse(XMLHttpRequest.responseText));
    }});
  }

  function initializeDataTables(){
    $('#list').dataTable({
      paging: false,
      order: [[0, "asc"]],
    });
    $('input.delete').click(function (event) {
      deleteTag(event.target.id.match(/delete_(.*)/)[1]);
    });
  }

  function hideNotice(){
    $('div#notice').fadeOut(1000);
    window.setTimeout(removeNotice, 1000);
  }

  function hideError(){
    $('div#error').fadeOut(1000);
    window.setTimeout(removeError, 1000);
  }

  function removeError(){
    $('div#error').remove();
  }

  function removeNotice(){
    $('div#notice').remove();
  }

  function deleteTag(tag){
    if (! window.confirm('Are you sure?')) {
      return false;
    }
    $.ajax({method: 'DELETE',
      url: '/mappings/' + tag,
      success: function (data, XMLHttpRequest, textStatus) {
        updateTable();
        $('.navigation').after("<div id='notice' class='flash'> Successfully deleted <a href='http://" +
                               window.location.host + "/" + tag + "'>http://" + window.location.host +
                               "/" + tag + "</a>.</div>");
        window.setTimeout(hideNotice, 5000);
      },
      error: function (XMLHttpRequest, textStatus) {
        console.log(XMLHttpRequest);
        $('.navigation').after("<div id='error' class='flash'>An error occurred: " + XMLHttpRequest.statusText + "</div>");
        window.setTimeout(hideError, 5000);
      }
    });
  }

  $('#shortener').submit(function () {

    var errors = 0;

    var input_url = $.trim($('input[name="url"]').val());
    var input_tag = $.trim($('input[name="tag"]').val());

    if(isEmpty(input_url)) {
      $('input[name="url"]').after("<div id='error' class='validation'>URL cannot be blank.</div>");
      window.setTimeout(hideError, 5000);
      errors++;
    }

    if(! isValidUrl(input_url)) {
      $('input[name="url"]').after("<div id='error' class='validation'>URL is not valid.</div>");
      window.setTimeout(hideError, 5000);
      errors++;
    }

    if(!isEmpty(input_tag) && ! isValidTag(input_tag)) {
      $('input[name="tag"]').after("<div id='error' class='validation'>Tag is not valid. Must be alphanumeric &mdash; 0-9, A-Z, a-z no spaces or symbols.</div>");
      window.setTimeout(hideError, 5000);
      errors++;
    }

    if(errors == 0) {
      $.ajax({method: 'POST',
        data: {
          url: input_url,
          tag: input_tag
        },
        url: '/mappings',
        success: function (data, XMLHttpRequest, textStatus) {
          updateTable();
          $('#tag').val('');
          $('#url').val('');
          $('.navigation').after("<div id='notice' class='flash'><a href='http://" + window.location.host +
                                 "/" + data.tag + "'>http://" + window.location.host + "/" + data.tag +
                                 "</a> now links to <a href='" + data.url + "'>" + data.url + "</a></div>");
          window.setTimeout(hideNotice, 5000);
        },
        error: function (XMLHttpRequest, textStatus) {
          $('#tag').val('');
          $('#url').val('');
          console.log(XMLHttpRequest);
          $('.navigation').after("<div id='error' class='flash'>An error occurred: " + XMLHttpRequest.statusText + "</div>");
          window.setTimeout(hideError, 5000);
        }
      });
    }
    return false;
  });
  updateTable();
});
