<script>
    $('body')
    .toast({
        title: '<?=$_SESSION['notification']['title']?>',
        message: '<?=$_SESSION['notification']['message']?>',
        showProgress: 'bottom',
        classProgress: '<?=$_SESSION['notification']['color']?>',
        progressUp: true
    })
;
</script>
