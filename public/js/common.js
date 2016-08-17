$('.deleteCmd').click(function() {
	var el = $(this).parent();
	if (confirm("この情報を削除してよろしいですか？")) {
		$.post('/delete', {
			id: el.data('id')
		}, function(){
			el.fadeOut(300);
		});
	}
});

function extraWait(){
	document.getElementById('extra').style.display='none';
	document.getElementById('extra2').style.display='none';
	document.getElementById('extra3').style.display='none';
	document.getElementById('wait_msg').style.display='block';
};
