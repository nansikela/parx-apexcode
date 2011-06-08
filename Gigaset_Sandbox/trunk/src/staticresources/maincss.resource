* { padding: 0; margin: 0; }
/* general */
body {
    background: #ededed url(../img/bg_body.jpg) repeat-x scroll 0 0;
    font-family: Arial, Verdana, Helvetica, sans-serif;
    font-size: 12px;
    font-weight:normal;
    line-height: 16px;
    color: #474c54;
    overflow-y:scroll;
}
a, a img {
    border:medium none;
    text-decoration:none;
    color: #474c54;
    cursor: pointer;
}
a:hover{
    color: #000000;
}
ul{
    list-style-type:none;
}
ol {
    list-style-position: inside;
    list-style-type:decimal;
    list-style:decimal;
}
h1 {
    font-size: 30px;
    margin-bottom:27px;
    font-weight: normal;
    display:block;
    line-height:normal;
}
h2 {
    font-size:18px;
    margin-bottom:30px;
    font-weight: normal;
}
h3 {
    font-size:13px;
    margin-bottom: 5px;
    font-weight: bold;
    float: left;
    width: 145px;
    margin-left: 10px;
}
sup, sub {
    height: 0;
    line-height: 1;
    vertical-align: baseline;
    _vertical-align: bottom;
    position: relative;
    
}
sup {
    bottom: 1ex;
}
sub {
    top: .5ex;
}
.rght {
     float: right!important;
     margin-right: 0px!important;
}
.cntr {
    margin-left: 65%!important;
}
.cntrTxt {
    margin-left: 35.5%!important;
}
.awards {
    bottom:0px;
    position:absolute;
    right:20px;
}
.lft, .left {
     float: left;
}
.clearBoth {
    clear: both;
}
img.lft {
    margin:0px 12px 10px 0 !important;
}
img.rght {
    margin:5px 0 10px 10px !important;
}
img.top {
    margin:-42px 0 10px 10px !important;
}
.marge {
     margin-left: 20px;
}
.margeRgt {
     margin-right: 17px!important;
}
.bold {
     font-weight: bold!important;
}
.curs {
     font-style:italic;
}
.white {
    color: #ffffff;
}
.orange {
    color: #FF9713!important;
}
.withoutBrd {
    border-bottom: none!important;
}
.validationError { 
    border-color: #ff0000;
}
#wrapper { 
     margin: 0 auto;
     width: 999px;
}
/* #shadow{ 
    background:transparent url(../img/bg_shadow.png) no-repeat scroll 0 100%;
    float:left;
    padding-bottom:13px;
    padding-left:13px;
    padding-right:17px;
} */
#content_area {
     background: #575f6a url(../img/bg_content.jpg) repeat-x scroll 0 0;
     padding: 0px 0px 30px 0px;
     float: left;
     width: 999px;
     overflow:hidden; 
}
/* header */
#header {
     width: 943px;
     height: 133px;
     padding: 0px 28px;
     margin: 0px;
     float:left;
     position:relative;
     z-index:1000;
}
#search {
    margin-left:754px;
    margin-top:55px;
    position:absolute;
    width:200px;
    z-index:20000;
}
#search fieldset {
    border: none;
}
#search .TypInput {
    background:url(../img/search_bg.png);
    background-color: transparent;
    background-repeat:no-repeat;
    border-width:0;
    height:25px;
    padding:0px 0px 0px 15px;
    width:153px;
    font-size: 11px;
    float: left;
}
#logo {
    position:relative;
    vertical-align: middle;
    top: 30px;
    margin-left: 400px;
}
#search button {
    background:transparent url(../img/surch_lens.png) no-repeat 0% 100%;
    border:0 none;
    height:25px;
    float: left;
    cursor: pointer;
    margin: 0px 0px 0px 0px;
}
#search button span {
    display: none;
}
button {
    background:url(../img/btn_front.png) no-repeat scroll 0 1px transparent;
    border:0 none;
    color:#FFFFFF !important;
    cursor:pointer !important;
    float:left;
    font-size:12px;
    font-weight:bold !important;
    margin:5px 0;
    padding:4px 0 15px 19px !important;
    position:relative;
    display:block;
    white-space:nowrap;
}
button span {
    background:url(../img/btn_back.png) no-repeat scroll 100% 0 transparent;
    border:0 none;
    color:#FFFFFF !important;
    padding:4px 15px 15px 5px;

}
button:hover, .buttonHover {
    background-image:url(../img/btn_frontL.png) no-repeat scroll 0 1px transparent;
}
button:hover span, .buttonHover span {
    background-image:url(../img/btn_backL.png) no-repeat scroll 100% 0 transparent;
}
button:active {
    padding: 1px 0px 0px 0px;
    margin-top:1px;
}
#content .oneColTop button {
    margin-top: 10px;
}
.trailer {
    position:absolute;
    left: 620px;
    top: 280px;
    height: 0px;
    width: auto;
    overflow: visible;
}
/* content */
#content { 
     width: 926px;
     background: #ffffff;
     margin: 11px 28px 0px 28px;
     padding: 0px 0px 0px 17px;
     float:left;
     min-height: 300px;
}
.content_back { 
     background:transparent url(../img/bg_contentpic.jpg) no-repeat scroll 0 0!important;
}
#content .contactBox {
    float:left;
    width:680px;
    margin-right: 10px;
    padding-bottom:30px;
}
#content #contact { 
     background:transparent url(../img/bg_konTop.png) no-repeat scroll 0 0;
     float:left;
     padding:17px;
     width:646px;
}
#content #end {
    background:transparent url(../img/bg_konBtm.png) no-repeat scroll 0 100%;
    float:left;
    width:680px;
    height:22px;
}
#content #contact h1 { 
    font-size:12px;
    font-weight:bold;
}
#content #contact p { 
    margin-bottom: 20px;
}
#content #contact form, #content #guarantee form { 
    float: left;
    width: 565px;
    padding-right: 150px;
    margin-bottom:20px;
}
#content #contact form label, #content #guarantee form label { 
    width: 210px;
    float:left;
}
#content #contact form select { 
    width: 354px!important;
    font-size: 11px;
    padding:1px;
    margin-bottom:5px;
}
#content #contact form input, form input, form select, form textarea { 
    font-size: 11px;
    padding:1px;
    margin-bottom:5px;
    font-family: Arial,Verdana,Helvetica,sans-serif;
}
#content #contact form textarea {
    height:100px;
    padding:1px;
    margin-bottom:5px;
}
#content #contact form .FieldRequired { 
    border: 1px solid #b2b2b2;
    width: 350px;
    margin-bottom:6px;
}
#content #contact form .radio{ 
    width: 350px;
    margin-bottom:6px;
    float:left;
}
#content #contact form .radio input { 
    margin-bottom:6px;
    float:left;
}
#content #contact form .radio label { 
    margin-bottom:6px;
    float:left;
    width:150px;
}
#content #contact form .check { 
    float: left;
    margin: 20px 0px;
    width: 500px;
}
#content #contact form .check input { 
    float: left;
}
#content #contact form .error { 
    color: #ff0000;
    margin-left:210px;
    margin-bottom:15px;
}
#content #contact form .validationError { 
    border-color: #ff0000;
}
#content #prodOver {
    width: 930px;
    position: relative;
}
#content #prodOver #rgtSide {
    float: left; 
    width:231px;
}
#content #prodOver #lftSide {
    float: left; 
    width:693px;
}
#content #prodOver .mood {
    margin-bottom: 8px;
}
#content #prodOver .oneCol {
    width:219px;
    margin:0 13px 13px -1px;
    float: left;
    position:relative;
}
#content #prodOver .oneColBtm {
    background:transparent url(../img/bg_oneColBtm.png) no-repeat scroll 0 0;
    height:9px;
    width:219px;
    float: left;
    position:relative;
}
#content #prodOver .oneColTop {
    background:transparent url(../img/bg_oneCol.png) no-repeat scroll 0 0;
    padding:10px 5px 0px 17px;
    width:197px;
    float: left;
    position:relative;
}
#content #prodOver .contentText {
    width:675px;
    float: left;
    position:relative;
    padding-right: 17px;
    padding-bottom: 20px;
}
#content #prodOver .contentText h1 {
    margin-bottom: 30px;
    float:left;
}
#content #prodOver .contentText p {
    clear:both;
}
#content #prodOver .contentText ul {
    margin: 5px 0;
}
#content #prodOver .contentText ul li {
    background:transparent url(../img/bullet.jpg) no-repeat scroll 0 7px;
    padding:0 0 0 10px;
    position: relative; 
    display:block;
}
#content #prodOver .contentText a {
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 50%;
    display:block;
    position:relative;
    font-weight:normal;
    padding-left:12px;
}
#content #prodOver .contentText a:hover {
    background:transparent url(../img/link_arrow_100black.gif) no-repeat scroll 0 50%;
    color:#000000;
}
#content #prodOver .contentTwoCol {
    width:447px;
    float: left;
    position:relative;
    padding-right: 17px;
    padding-bottom: 20px;
}
#content #prodOver .contentTwoCol hr {
    background-color:#DCDCDC; 
    color:#DCDCDC; 
    border: #DCDCDC; 
    height: 1px;
    margin: 25px 0;
    clear:both;
}
#content #prodOver .contentTwoCol h1 {
    margin-bottom: 30px;
    float:left;
}
#content #prodOver .contentTwoCol h2 {
    font-size: 12px;
    font-weight:bold;
    float: none;
    margin: 0px;
    width: auto;
}
#content #prodOver .contentTwoCol p {
    clear:both;
}
#content #prodOver .contentTwoCol ul {
    margin: 5px 0;
}
#content #prodOver .contentTwoCol ul li {
    background:transparent url(../img/bullet.jpg) no-repeat scroll 0 7px;
    padding:0 0 0 10px;
    position: relative; 
    display:block;
}
#content #prodOver .contentTwoCol a {
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 50%;
    display:block;
    position:relative;
    font-weight:normal;
    padding-left:12px;
}
#content #prodOver .contentTwoCol a:hover {
    background:transparent url(../img/link_arrow_100black.gif) no-repeat scroll 0 50%;
    color:#000000;
}
#content #prodOver .oneColInfo {
    background:transparent url(../img/bg_oneCol.png) no-repeat scroll 0 0;
    padding:10px 5px 0px 17px;
    width:197px;
    float: left;
    position:relative;
}
#content #prodOver .oneColInfo .FieldRequired {
    width:180px;
    margin-bottom: 5px;
}
#content #prodOver .oneColInfo select.FieldRequired {
    color: #474C54;
    font-size: 12px;
    font-family: Arial,Verdana,Helvetica,sans-serif;
    line-height: 1.5;
    font-weight: normal;
}
#content #prodOver .oneColInfo h2 {
    font-size: 12px;
    font-weight: bold;
    margin-bottom: 10px;
}
#content #prodOver .oneColInfo p, #content #prodOver .oneColInfo ul  {
    margin-bottom: 10px;
}
#content #prodOver .oneColInfo a {
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 50%;
    display:block;
    position:relative;
    font-weight:normal;
    padding-left:12px;
}
#content #prodOver .oneColInfo a:hover {
    background:transparent url(../img/link_arrow_100black.gif) no-repeat scroll 0 50%;
    color:#000000;
}
#content #prodOver .oneColTop .compare {
    float:left;
    margin-left:-1px;
    width:65px;
}
#content #prodOver .oneColTop .compare img {
    border: 1px solid #efefef;
}
#content #prodOver .oneColTop .compare span {
    font-size: 9px;
}
#content #prodOver .oneColTop .text {
    height: 65px; /* 20091218 */
    overflow:hidden;
}
#content #prodOver .oneColTop .price {
    font-size: 18px;
    margin:10px 0;
    height:20px; /* 20091218 */
}
#content #prodOver .oneColTop .stoerer {
    position:absolute;
    height:83px;
    width:83px;
    right:3px;
    top:3px;
}
#content #prodOver .oneColTop input { 
    float:left;
    margin-right:5px;
    margin-top:3px;
}
#content #prodOver .oneColTop span.check { 
    float: left;
    width:170px;
}
#content #prodOver #category { 
    background-color:#FFFFFF;
    border:1px solid #EFEFEF;
    float:left;
    left:17px;
    padding:5px;
    position:absolute;
    top:60px;
}
#content #prodOver #category p { 
    float:left;
}
#content #prodOver #category input { 
    margin-left:10px;
    margin-right:2px;
}
#content #prodSearch {
    float: left; 
    width: 909px;
    position: relative;
}
#content #prodSearch h1, #content #prodOver h1 { 
    font-size:18px;
    font-weight:normal;
    margin-bottom:14px;
}
#content #prodSearch .searchProducts { 
    float: left;
    border-bottom:1px solid #DCDCDC;
    width: 903px;
    margin-left:3px;
    position:relative;
    display:block;
}
#content #prodSearch .searchProducts h2 { 
    font-size:12px;
    font-weight:bold;
    margin-top: 30px;
}
#content #prodSearch .searchProducts .sum { 
    float: left;
    position: relative;
    display:block;
    z-index:500;
    width: 500px;
    padding:0 0 30px 150px;
    overflow:hidden;
}
#content #prodSearch .searchProducts .sumNoPic { 
    float: left;
    position: relative;
    display:block;
    z-index:500;
    width: 660px;
    padding:0 0 30px 0px;
    overflow:hidden;
}
#content #prodSearch .searchProducts .sum .sumImg { 
    position: absolute;
    left:0;
    width:145px;
    overflow:hidden;
}
#content #prodSearch .searchProducts .sum a { 
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 50%;
    padding-left: 12px;
}
#content #prodSearch .searchProducts .sum a:hover { 
    background:transparent url(../img/link_arrow_100black.gif) no-repeat scroll 0 50%;
}
#content #prodSearch .searchProducts .sum h3, #content #prodSearch .searchProducts .sumNoPic h3 { 
    font-size: 12px;
    font-weight: bold;
    margin:0;
    width:auto;
    float:none;
}
#content #linknavi { 
     width:234px;
     margin-bottom: 20px;
     float:left
}
#content #linknavi h1 { 
     font-size: 18px;
     font-weight: normal;
     line-height: 1.2;
     margin-top: 7px;
}
#content .prodThreeColsText h1 { 
     font-size: 18px;
     font-weight: normal;
     line-height: 1.2;
     padding: 0px 0px 0px 17px;
}
#content #linknaviTop { 
     background:transparent url(../img/bg_navtop.png) no-repeat scroll 0 0;
     float:left;
     margin-left:-5px;
     padding:10px 5px 30px 17px;
     width:212px;
}
#content #linknaviTop ul.conPad {
    padding-left: 10px;
}
#content #linknaviTop ul li { 
    background:transparent url(../img/ico_arrow.gif) no-repeat scroll 0px 5px;
    padding-left:10px;
}
#content #linknaviBtm { 
     background:transparent url(../img/bg_navbtm.png) no-repeat scroll 0 0!important;
     margin-left:-5px;
     padding:0 0 0 17px;
     width:234px;
     height: 20px;
     float:left
}
#content .prodTeaserBigShad {
    background:transparent url(../img/prodTeaserBig.jpg) no-repeat scroll 50% 0;
    margin-left:-14px;
    margin-top:-10px;
    padding-left:12px;
    padding-top:6px;
    width:925px;
    float:left;
    position:relative;
    margin-bottom:23px;
}
#content .prodTeaserBigShad .colors {
    background:#EEEEF0 url(../img/prodTeaserBigBottom.jpg) no-repeat scroll 50% 100%;
    float:left;
    height:55px;
    margin:40px 0px -7px 1px;
    padding:3px 20px 12px 18px;
    position:relative;
    width:870px;
}
#content .prodTeaserBigShad .overview{
    background:transparent url(../img/prodTeaserBigBottom.jpg) no-repeat scroll 50% 100%;
    float:left;
    margin-bottom:-7px;
    padding:3px 20px 12px 18px;
    position:relative;
    width:880px;
}
.topFaq {
    margin:0 0 10px!important;
}
.topFaq a {
    font-weight:normal!important;
}
#content .faqBigShad .btm {
    background:url("../img/prodTeaserBigBottom1.jpg") no-repeat scroll 0 0 transparent;
    bottom:0;
    height:9px;
    left:3px;
    position:absolute;
    width:921px;
}
#content .prodTeaserBigShad .colors p {
    margin: 10px 15px 0px 0px;
}
#content .prodTeaserBigShad .colors .info {
    margin: 10px 10px 0px 0px;
}
#content .prodTeaserBigShad .colors .prodcols{
    margin-top: 20px;
}
#content .prodTeaserBigShad .colors .choose {
    margin: 0px 10px 0px 0px;
}
#content .prodTeaserBigShad .colors a {
    font-weight: normal!important;
    color: #474c54!important;
    float: left;
}
#content .prodTeaserBigShad .colors img {
    border:1px solid #d6d7d8;
    margin-right:2px;
}
#content .prodTeaserBigShad .colors img:hover {
    border:1px solid #FF9713;
}
#content .prodThreeColsText {
    background:transparent url(../img/bg_textTop.png) no-repeat scroll 50% 0;
    padding: 16px 0 0 12px;
    margin: -10px 0 10px -11px;
    width:925px;
    float:left;
}
#content .prodThreeColsText .text {
    width:267px;
    float:left;
    margin: 5px 10px 15px 17px;
    position:relative;
    display:block;
}
#content .prodThreeColsText .text h3 {
    float:none;
    margin-bottom:0px;
    margin-left:0px;
    width:auto;
}
#content .prodThreeColsSh {
    background:transparent url(../img/prodTeaser3small.png) no-repeat scroll 50% 0;
    margin-left:-12px;
    margin-top:-10px;
    padding-left:12px;
    padding-top:16px;
    width:925px;
    height: 184px; 
    float:left;
}
#content .prodThreeColsSh p {
    margin-left:10px;
    width:125px;
    float:left;
}
#content .prodThreeColsSh .products {
    margin-top: 15px;
}
#content .prodThreeColsSh .teaser:hover * {
    color: #000000;
}
.prodThreeColsSh li:hover * {
    color: #000000;
}
#content .prodThreeColsSh .teaser {
    border-left:2px solid #EFEFEF;
    float:left;
    margin-left:-1px;
    padding:0 20px 0 40px;
    position:relative;
    width:245px;
}
#content .prodThreeColsSh .teaser p {
    margin-left:10px;
    width:125px;
    float:left;
}
#content .prodOneCols {
    background:transparent url(../img/prodTeaserOne.jpg) no-repeat scroll 50% 0;
    margin-left:-13px;
    margin-top:-10px;
    padding-left:12px;
    padding-top:16px;
    width:228px;
    height: 184px; 
    position: relative;
}
#content .prodTeaserBig {
    width: 907px;
    border: 1px solid #ffffff;
    position:relative;
    float:left;
}
#content .prodTeaserBig .sumLong { 
    float:left;
    margin-left:17px;
    padding:0 0 10px;
    margin:25px 0 0 17px;
    position:relative;
    width:873px;
}
#content .prodTeaserBig .sumLong h3 { 
    font-size: 12px;
    font-weight: bold;
    margin:0;
    width:auto;
    float:none;
}
/* #content .prodTeaserBig .sumLong h1 { 
    margin-bottom: 0px;
} 
#content .prodTeaserBig .sumLong h2 { 
    margin-bottom: 10px;
}*/
#content .prodTeaserBig .sumLong p { 
    padding-bottom: 10px;
}
#content .prodTeaserBig .sum { 
    border-bottom:1px solid #DCDCDC;
    float:left;
    margin-left:17px;
    padding:0 0 30px 150px;
    margin:25px 0 0 17px;
    position:relative;
    width:723px;
}
#content .prodTeaserBig .sum .description { 
    float:left;
    margin-right:23px;
    width:450px;
}
#content .prodTeaserBig .sum ul.list { 
    background: none;
    width:250px;
    float:left;
}
#content .prodTeaserBig .sum ul.list li { 
    background:transparent url(../img/bullet.jpg) no-repeat scroll 0 7px;
    padding:0 0 0 10px;
}
#content .prodTeaserBig .sum img { 
    position: absolute;
    left:0;
}
#content .prodTeaserBig .sum a, #content .prodTeaserBig .sumLong a { 
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 50%;
    padding-left: 12px;
    display:block;
    font-weight:normal;
}
#content .prodTeaserBig .sum a:hover, #content .prodTeaserBig .sumLong a:hover { 
    background:transparent url(../img/link_arrow_100black.gif) no-repeat scroll 0 50%;
    color:#000000;
}
#content .prodTeaserBig .sum h3 { 
    font-size: 12px;
    font-weight: bold;
    margin:0;
    width:auto;
    float:none;
}
#content .prodTeaserBig .download {
    width: 875px;
    border-bottom: 1px solid #dcdcdc;
    float:left;
    margin-left: 17px;
    margin-top: 20px;
}
.download h3 {
    font-size:12px;
    margin-bottom: 5px;
    font-weight: bold;
    float: none;
    margin-left: 0px;
    width:auto;
}
/* .download p {
    margin-bottom: 5px;
} */
#content .prodTeaserBig .download ul {
    background: none;
    margin-bottom: 5px;
    width:100%; 
}
#content .prodTeaserBig .download ul li, #content .comp ul li {
    padding: 0;
    clear:both;
    background:transparent url(../img/bullet.jpg) no-repeat scroll 0 7px;
    font-weight:normal;
    padding:0 0 0 10px;
}
.sitemapMainNav {
    padding:16px 0px 0px 50px;
    display:block;
}

.sitemapMainNavWrapper {
    padding:16px 20px 0px 0px;
    display:block;
}

.sitemapMetaNav {
    padding:16px 20px 0px 0px;
    display:block;
}

.sitemapPageFooterNav {
    padding:16px 20px 0px 0px;
    display:block;
}
ol {
    clear:both;
    display:block;
    float:left;
    position:relative;
    width:100%;
}
ol li {
    clear:both!important;
    background:none!important;
    padding:0px!important;
    list-style:decimal!important;
    list-style-type:decimal!important;
    list-style-position:inside!important;
    float:none!important;
}
#content .prodTeaserBig .download ul li ul li, #content .comp ul li {
    background:transparent url(../img/strich.gif) no-repeat scroll 0 6px;
    font-weight:normal;
    list-style:none;
    margin-left:15px;
    padding:0 0 0 10px;
    width:100%;
}
.download button {
    background: transparent url(../img/downloadpdf_front.gif) no-repeat 0% 30%;
    border:0 none;
    color:#FFFFFF !important;
    font-size: 12px;
    font-weight: bold;
    height:30px;
    margin:5px 0px;
    cursor: pointer;
}
.download button span {
    background: transparent url(../img/download_back.gif) no-repeat 100% 0%;
    border:0 none;
    color:#FFFFFF !important;
    height:30px;
    margin-left:1px;
    padding:3px 15px 12px 1px;
}
.download a.exe, #content #prodOver .contentText .download a.exe, #content #prodOver .contentTwoCol .download a.exe {
    background-image:url(../img/downloadexe_front.gif);
}
.download a, #content #prodOver .contentText .download a, #content #prodOver .contentTwoCol .download a {
    background:url("../img/downloadpdf_front.gif") no-repeat scroll 0 0 transparent;
    border:0 none;
    color:#FFFFFF !important;
    cursor:pointer;
    display:block;
    float:left;
    font-size:12px;
    height:30px;
    margin:5px 0;
    padding:0 0 0 23px;
    position:relative;
}
.download a span, #content #prodOver .contentText .download a span, #content #prodOver .contentTwoCol .download a span {
    background:url("../img/download_back.gif") no-repeat scroll 100% 0 transparent;
    border:0 none;
    color:#FFFFFF !important;
    display:inline-block;
    overflow:hidden;
    height:30px;
    padding:4px 15px 0 5px;
    position:relative;
}
.download a:hover, #content #prodOver .contentText .download a:hover, #content #prodOver .contentTwoCol .download a:hover {
    background-image:url(../img/downloadpdf_frontL.gif);
}
.download a.exe:hover, #content #prodOver .contentText .download a.exe:hover, #content #prodOver .contentTwoCol .download a.exe:hover {
    background-image:url(../img/downloadexe_frontL.gif);
}
.download a:hover span, #content #prodOver .contentText .download a:hover span, #content #prodOver .contentTwoCol .download a:hover span {
    background-image:url(../img/download_backL.gif);
}
.download button.exe {
    background-image:url(../img/downloadexe_front.gif);
}
.download button:hover, .buttonHover {
    background-image:url(../img/downloadpdf_frontL.gif);
}
.download button.exe:hover {
    background-image:url(../img/downloadexe_frontL.gif);
}
.download button:hover span, .buttonHover span {
    background-image:url(../img/download_backL.gif);
}
#content .prodTeaserBig .buy {
    position: relative;
    display:block;
    clear:both;
    width:265px;
    padding-top:20px;
}
#content .prodTeaserBig .buyFrench {
    clear:both;
    display:block;
    position:relative;
    width:265px;
    padding-top:30px;
}
#content .prodTeaserBig .buyFrench .priceBtn {
    margin-top:-4px;
}
#content .prodTeaserBig .priceBtn {
    display:block;
    float:right;
    position:relative;
}
#content .prodTeaserBig .priceBtn a {
    background:url("../img/btn_front.png") no-repeat scroll 0 0 transparent !important;
    border:0 none;
    color:#FFFFFF !important;
    cursor:pointer !important;
    float:left;
    font-size:12px;
    font-weight:bold !important;
    height:30px;
    margin:5px 0;
    padding:0 0 0 24px !important;
    white-space:nowrap;
}
#content .prodTeaserBig .priceBtn a span {
    background:url("../img/btn_back.png") no-repeat scroll 100% 0 transparent;
    border:0 none;
    color:#FFFFFF !important;
    display:block;
    height:30px;
    display:inline-block;
    overflow:hidden;
    padding:4px 20px 0 5px !important;
    position:relative;
}
#content .prodTeaserBig .priceBtn a:hover {
    background:transparent url(../img/btn_frontL.png) no-repeat scroll 0 0!important;
}
#content .prodTeaserBig .priceBtn a:hover span {
    background:transparent url(../img/btn_backL.png) no-repeat scroll 100% 0;
}
/* buttons */
a.btn {
    background:url("../img/btn_front.png") no-repeat scroll 0 0 transparent !important;
    border:0 none;
    color:#FFFFFF !important;
    cursor:pointer !important;
    float:left;
    font-size:12px;
    font-weight:bold !important;
    height:30px;
    margin:5px 0;
    padding:0 0 0 24px !important;
    white-space:nowrap;
    overflow:visible;
    position:relative;
    width:auto;
}
a.btn span {
    background:url("../img/btn_back.png") no-repeat scroll 100% 0 transparent;
    border:0 none;
    color:#FFFFFF !important;
    display:inline-block;
    overflow:hidden;
    height:30px;
    padding:4px 20px 0 5px !important;
    position:relative;
}
a.btn:hover {
    background:transparent url(../img/btn_frontL.png) no-repeat scroll 0 0!important;
}
a.btn:hover span {
    background:transparent url(../img/btn_backL.png) no-repeat scroll 100% 0;
}
#content .prodTeaserBig table.all {
    width: 875px;
    margin: 20px 0px 0px 17px;
    float:left;
}
#content .prodTeaserBig .comp table {
    margin: 0px;
}
#content .prodTeaserBig table .bg {
    background:transparent url(../img/bg_table.jpg) repeat-x scroll 0 0;
}
#content .prodTeaserBig table td.headline {
    border:1px solid #CCCCCC;
    padding:5px 17px;
    font-weight:bold;
}
#content .prodTeaserBig table td {
    padding:5px 17px;
}
#content .prodTeaserBig table .gray {
    background-color:#F0F0F0;
}
#content .prodTeaserBig .linkbox {
    background:transparent url(../img/serviceteaser.jpg) no-repeat scroll 50% 0;
    width: 235px;
    height: 76px;
    float: left;
    margin: 20px 0px 25px 13px;
    padding: 40px 0 0 50px;
}
#content .prodTeaserBig .linkbox h3 {
    width: 185px;
}
#content .prodTeaserBig .linkbox a {
    color:#474C54;
}
#content .prodTeaserBig .comp {
    float:left;
    margin:0 16px 0 17px;
    width:420px;
}
#content .prodTeaserBig .comp ul {
    background: none!important;
    width:auto!important;
}
#content .prodTeaserBig .comp ul li {
    padding:13px 13px 0px 0px;
}
/* 20091217 RICH TREE Start */
#content .prodTeaserBig .comp .rich-tree table {
    margin:0px;
    text-align:left;
    width: 400px;
}
#content .prodTeaserBig .comp .rich-tree table img {
    padding-top: 3px;
}
#content .prodTeaserBig .comp .rich-tree table td.rich-tree-node-handleicon  {
    padding:2px 0px;
}
#content .prodTeaserBig .comp .rich-tree table td.rich-tree-node-icon, #content .prodTeaserBig .comp .rich-tree table td.rich-tree-node-icon-leaf {
    display:none;
}
#content .prodTeaserBig .comp .rich-tree table .rich-tree-node-handleicon  {
    width: 10px;
}
#content .prodTeaserBig .comp .rich-tree table .rich-tree-node-handleicon div  {
    width: 10px;
}
#content .prodTeaserBig .comp .rich-tree table .rich-tree-node-text {
    padding:2px 0px;
}
#content .prodTeaserBig .comp .rich-tree table .rich-tree-node-selected {
    border-style: none;
}
/* 20091217 RICH TREE End */

#content .prodTeaserBig .comp ul.register, #content .prodTeaserBig .comp ul.register ul, #content .faqBig .comp ul.register, #content .faqBig .comp ul.register ul {
    background: none;
    width:400px;
    float:none;
}
#content .prodTeaserBig .comp ul.faq {
    background: none;
    float:left;
    width:200px;
}
#content .prodTeaserBig .comp ul.register li, #content .faqBig .comp ul.register li {
    float: none;
    padding: 3px 0px;
    font-weight: bold;
    list-style:decimal;
    list-style-position:inside;
}
#content .prodTeaserBig .comp ul.register li ul li, #content .faqBig .comp ul.register li ul li {
    border:1px solid #b2b2b2;
    list-style-image:none;
    list-style-position:outside;
    list-style-type:none;
    margin:15px 0;
    padding-left:10px;
    width:400px;
}
#content .prodTeaserBig .comp ul.register li img, #content .faqBig .comp ul.register li img {
    float: none;
}
#content .prodTeaserBig .comp ul.faq li {
    float: none;
    background:transparent url(../img/bullet.jpg) no-repeat scroll 0 7px;
    padding:0 0 0 10px;
}
#content .prodTeaserBig .comp ul.faqNavi {
    background: none;
    float:left;
}
#content .prodTeaserBig .comp ul.faqNavi ul {
    background: none;
}
#content .prodTeaserBig .comp ul.faqNavi li {
    background: url(../img/faqNavi.jpg) no-repeat 0% 5px;
    padding:0 0 0 11px;
}
#content .prodTeaserBig .comp ul.faqNavi li.down {
    background: url(../img/faqNavidown.jpg) no-repeat 0% 5px;
}
#content .prodTeaserBig .comp ul.faqNavi li ul li ul li {
    background: none;
    padding-left: 5px;
    float: none;
}
#content .prodTeaserBig .comp ul.faqNavi a {
    font-weight: normal;
}
#content .prodTeaserBig .comp h1, #content .faqBig .comp h1 {
    width: 410px;
    margin: 0px 0px 10px 0px;
    float:left;
    font-size:13px;
    font-weight:bold;
}
#content .prodTeaserBig .comp h2, #content .faqBig .comp h2 {
    width: 410px;
    margin: 0px 0px 0px 0px;
    float:left;
    font-size:12px;
    font-weight:bold;
}
#content .prodTeaserBig .comp p, #content .faqBig .comp p {
    margin: 0px 0px 20px 0px;
}
#content .prodTeaserBig .compProduct, #content .faqBig .comp .compProduct {
    width: 150px;
    margin-bottom: 20px;
    margin-right:30px !important;
}
#content .prodTeaserBig .compProduct button, #content .faqBig .comp .compProduct button {
    margin-top:20px;
    margin-left: 5px;
}
#content .prodTeaserBig .compProduct .TypFilter, #content .faqBig .comp .compProduct .TypFilter {
    width: 165px;
    margin: 0px 0px 20px 0px;
    font-size: 10px;
}
#content .prodTeaserBig .comp table a, #content .faqBig .comp table.compatibilityTable a {
    font-weight: normal;
}
#content .prodTeaserBig .comp table, #content .faqBig .comp table.compatibilityTable {
    float:left;
    text-align:left;
    border-bottom: 1px solid #cccccc;
    border-top: 1px solid #cccccc;
    width:420px;
}
#content .prodTeaserBig .comp .rich-tree table {
    border: none!important;
}
#content .prodTeaserBig .comp table .center, #content .faqBig .comp table.compatibilityTable .center {
    text-align:center;
}
#content .prodTeaserBig .comp table .gray, #content .faqBig .comp table.compatibilityTable .gray {
    background-color: #f0f0f0;
}
#content .prodTeaserBig .comp table .bg, #content .faqBig .comp table.compatibilityTable .bg {
    background: url(../img/bg_table.jpg) repeat-x 0% 0%;
}
#content .prodTeaserBig .comp table th, #content .faqBig .comp table.compatibilityTable th {
    border-bottom: 1px solid #cccccc;
    padding: 5px 17px;
    text-align:left;
}
#content .prodTeaserBig .comp table td, #content .faqBig .comp table.compatibilityTable td {
    padding: 2px 17px;
}
#content .prodTeaserBig .comp table .brdLft, #content .faqBig .comp table.compatibilityTable .brdLft {
    border-left: 1px solid #cccccc;
}
#content .prodTeaserBig .comp table .brdRgt, #content .faqBig .comp table.compatibilityTable .brdRgt {
    border-left: 1px solid #cccccc;
    border-right: 1px solid #cccccc;
}
#content .prodTeaserBig .uvp {
    clear:both;
    float:left;
    font-size:10px;
    margin-top:-10px;
}
#content .prodTeaserBig .advice {
    font-size: 12px;
    padding-top:10px;
    float:left;
    clear:both;
}
#content .prodTeaserBig .price {
    font-size: 24px;
    padding-top:10px;
    float:left;
    clear:both;
    min-height:30px;
    height:auto!important;
    height:30px;
}
#contentAll {  /* 20091217 */
    margin-bottom:-34px;
    padding-top:10px;
    float:left;
    position:relative;
    min-height: 300px;
}
#contentStart { 
     width: 926px;
     margin: 0px 28px 0px 28px; /* 20091217 */
     padding: 0px 0px 30px 17px; /* 20091217 */
     background: url(../img/shadow_nav.png) no-repeat 50% 0%;
     color: #ffffff!important;
     float: left;
}
#contentStart #description {
    width: 260px;
}
#gigaset, .gigaset {
    margin-top: 20px;
    clear:both;
}
#gigaset li, .gigaset li {
    float: left;
    margin-right: 5px;
}
#description {
    float:left;
    padding: 45px 30px 0px 140px;
}
.prodTeaserBig #description {
    float:left;
    padding: 45px 30px 0px 80px;
    width: 260px;
}
.prodTeaserBig #description ul {
    background: transparent!important;
    width: auto;
}
.prodTeaserBig #description ul li { /* 20091217  */
    background:transparent url(../img/ico_bullet.gif) no-repeat scroll 3px 5px;
    float:none;
    list-style-type:none;
    padding:0 0 0 17px;
    width:260px;
}
#description #infos li { /* 20091217  */
    background:transparent url(../img/ico_bulletwh.gif) no-repeat scroll 3px 5px;
    float:none;
    list-style-type:none;
    padding:0 0 0 17px;
    width:300px;
}
.prodTeaserBig #description #infos li { /* 20091217  */
    background:transparent url(../img/ico_bullet.gif) no-repeat scroll 3px 5px;
    float:none;
    list-style-type:none;
    padding:0 0 0 17px;
    width:300px;    
}
#content .prodTeaserBig #description a {
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 1px 60%;
    float:left;
    font-weight:normal;
    padding:0 0 0 17px;
}

#content .prodTeaserBig #description a#morelink {
    margin:0px;
}


#description a {
    background:transparent url(../img/link_arrow_withe_trans.png) no-repeat scroll 1px 60%;
    color: #ACB0BB;
    float:left;
    font-weight:normal;
    padding:0 0 0 17px;
    margin-bottom: 20px;
}
#content .prodTeaserBig #description #gigaset a, #description #gigaset a, #description .gigaset a {
    background:none;
    padding:0;
}
#content .prodTeaserBig #description a:hover {
    color: #000000;
}
#description a:hover {
    color: #ffffff;
}
.prodTeaserBig #description #gigaset, .prodTeaserBig #description .gigaset {
    clear:both;
    margin-left:18px;
}
.prodTeaserBig #description #gigaset li, .prodTeaserBig #description .gigaset li {
    padding: 0px;
    list-style-image:none;
    list-style-position:outside;
    list-style-type:none;
    float:left;
    width:auto;
    background:none; /* 20100201 */
}
.product {
    float:left;
    margin: 45px 0px 0px 0px;
}
.footnote {
     font-size: 9px;
     color: #727272;
     line-height: 1.2;
     margin:0px 18px 10px 0px;
     float: left;
}
ul.teaserNoSlide {
    clear: both;
    padding-top:10px;
}
ul.teaserNoSlide li {
    height:115px;
    width:283px;
    position: relative;
    margin-left: 10px;
    margin-right: 10px;
    float: left;
}
.prodThreeColsSh li a.tsrLnk {
    display:block;
    height:110px;
    left:-3px;
    position:absolute;
    top:0;
    width:95%;
    z-index:500;
    background-color: transparent;
}
/* breadcrumbs */
#breadcrumbs { 
     color: #989898;
     font-size: 10px;
     padding: 15px 0px 17px 0px;
     float: left;
     width: 900px;
}
#breadcrumbs p { 
     float: left;
     width:750px;
}
#breadcrumbs h2.breadcumb {
     color: #989898;
     font-size: 10px;
     float: left;
}
#breadcrumbs span, #breadcrumbs span a, #breadcrumbs h2.breadcumb, #breadcrumbs h2.breadcumb a { 
     color: #000000;
     float: left;
     margin-right: 2px;
     margin-bottom: 0px;
}
#breadcrumbs span a:hover, #breadcrumbs h2.breadcumb a:hover { 
     color: #000000;
}
#breadcrumbs span.tell {
    float:right;
    width: 120px;
}
#breadcrumbs span.tell a {
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 60%;
    padding-left:10px;
    display: block;
    position:relative;
}
#breadcrumbs span.tell a:hover {
    background:transparent url(../img/link_arrow_100black.gif) no-repeat scroll 0 60%;
}
#breadcrumbs span.tell img{
    padding:3px 0 0 3px;
}
/* footer */
#footer { 
     background: #575f6a url(../img/bg_footer.jpg) repeat-x scroll 0 0;
     color: #acb0bb;
     width: 943px;
     padding:30px 28px 20px;
     display: block;
     position: relative;
     float: left;
     overflow:hidden;
}
.one {
    padding-left: 50px;
}
#footer .teaser, #footer .teaser img, #footer .teaser p {
    float: left;
}
#footer .teaser {
    width: 295px;
    margin: 10px 0px 40px 0px;
    position:relative;
    display:block;
    z-index:500;
}
#footer .teaser p {
    margin-left: 10px;
    width: 125px;
}
#footer .siemens {
    width:943px;
    float:left;
}
#footer span {
    clear:both;
}
#footer ul { 
     font-weight: bold;
}
#footer ul.rght { 
     margin-right: -55px!important;
}
#footer ul li { 
     width: auto;
     float:left;
     margin-right: 20px;
}
#footer ul li ul li { 
    float: none;
}
#footer ul li a { 
     color: #ffffff;
}
#footer ul li ul li a { 
     font-weight: normal;
     color:#ffffff;
}
#footerlogos {
    float:left;
    margin:35px 0 0;
    width:943px;
}
#footer_copy { 
     color: #929292;
     font-size: 9px;
     height: 50px;
     padding: 5px 0px 0px 0px;
     margin: 0px 0px 10px 0px;
     float: left;
    text-align: center;
    width: 100%;
}
#footer_copy a { 
     color: #929292;
}
#footer_copy a:hover, #footer_copy aHover  { 
     color: #000000;
}
#footer_copy a.icons {
    margin-left: 10px;
}
#footer_copy p {
    text-align: center;
}
#footer_copy div.footerLinks {
    margin-top: 10px;
    text-align: center;
}
/* navigation menu list */
ul#metanavi {
    list-style: none;
    font-size: 11px;
    z-index: 1000;
    float: right;
}
ul#metanavi li {
    float: left;
    list-style: none;
    position: relative;
    padding: 13px 0px 0px 15px;
}
ul#metanavi a {
    color: #acb0bb;
}
ul#metanavi a:hover, ul#metanavi aHover, ul#metanavi .active {
    color: #ffffff;
}
#content .prodTeaserBig ul {
    background: url(../img/bg_prod.jpg) repeat-x scroll 0 0;
    list-style: none;
    z-index: 500;
    float: left;
    width:909px;
}
#content .prodTeaserBig li {
    float: left;
    list-style: none;
    position: relative;
    padding: 13px 13px 0px 17px;
}
#content .prodTeaserBig a {
    color: #727272;
    font-weight:bold;
}
#content .prodTeaserBig a.active,#content .prodTeaserBig a:hover, #content .prodTeaserBig aHover {
    color: #FF9713;
}
ul#Navigation {
    list-style: none;
    position:relative;
    float:left;
    top: 43px;
    font-weight: bold;
    color: #ffffff;
    width: 999px;
    z-index: 500;
}
ul#Navigation li {
    float: left;
    list-style: none;
    position: relative;
}
ul#Navigation ul {
    width: 199px;
    list-style: none;
    display: none;
    position: absolute;
    top:56px;
    left: -6px;
    padding-bottom:8px;
    background-color: #ededed;
    background:transparent url(../img/nav_dropdown_hg.png) no-repeat scroll 100% 100%;
}
ul#Navigation ul li {
    display: block !important;
    width: 183px;
    margin-left:8px;
}
/* Root Menu */
ul#Navigation a {
    padding: 20px 18px;
    float: none !important;
/*For Opera*/
    display: block;
    color: #ffffff;
}
ul#Navigation a.activate {
    color: #ff9713;
}
/* Root Menu Hover Persistence */
ul#Navigation li:hover a, ul#Navigation li.iehover a {
    color: #ff9713;
    background-color: #535760; 
}
/* 2nd Menu */
ul#Navigation li:hover li a, ul#Navigation li.iehover li a {
    float: none;
    padding: 8px 5px 8px 15px;
    color:#47484d;
    min-height: 1.5em;
    height: auto!important;
    background-color: transparent; 
    height: 1.5em;
}
/* 2nd Menu Hover Persistence */
ul#Navigation li:hover li a:hover, ul#Navigation li:hover li:hover a, ul#Navigation li.iehover li a:hover, ul#Navigation li.iehover li.iehover a {
    background-color: #c8c9cd;
}
/* 3rd Menu */
ul#Navigation li:hover li:hover li a, ul#Navigation li.iehover li.iehover li a {
    background: transparent none;
    color: #040404;
}
/* 3rd Menu Hover Persistence */
ul#Navigation li:hover li:hover li a:hover, ul#Navigation li:hover li:hover li:hover a, ul#Navigation li.iehover li.iehover li a:hover, ul#Navigation li.iehover li.iehover li.iehover a {
    background: transparent url("/media/_entwickler/images/navigation/bg_navi_main_2.png") 0 0 repeat-x;
    color: #fff;
}
/* 4th Menu */
ul#Navigation li:hover li:hover li:hover li a, ul#Navigation li.iehover li.iehover li.iehover li a {
    background: transparent none;
    color: #040404;
}
/* 4th Menu Hover */
ul#Navigation li:hover li:hover li:hover li a:hover, ul#Navigation li.iehover li.iehover li.iehover li a:hover {
    background: transparent url("/media/_entwickler/images/navigation/bg_navi_main_2.png") 0 0 repeat-x;
    color: #fff;
}
ul#Navigation ul ul {
    display: none;
    background: transparent url("/media/_entwickler/images/navigation/bg_navi_expanded_1.png") 0 100%;
    position: absolute;
    top: 0px;
    left: 152px;
    padding: 0 8px 8px 8px;
}
ul#Navigation ul ul ul {
    top: 0px;
    left: 152px;
    padding: 0 8px 8px 8px;
}
/* Do Not Move - Must Come Before display:block for Gecko */
ul#Navigation li:hover ul ul, ul#Navigation li:hover ul ul ul, ul#Navigation li.iehover ul ul, ul#Navigation li.iehover ul ul ul {
    display: none;
}
ul#Navigation li:hover ul, ul#Navigation ul li:hover ul, ul#Navigation ul ul li:hover ul, ul#Navigation li.iehover ul, ul#Navigation ul li.iehover ul, ul#Navigation ul ul li.iehover ul {
    display: block;
}
#main ul#Navigation li a.active {
    font-weight: bold!important;
}
/* tooltip */
#tooltip{
    position:absolute;
    padding:2px 5px;
    color:#000000;
    display:none;
    font-weight: bold!important;
    margin-top: 20px;
}
/* summenlink */
.teaser a.tsrLnk {
    display:block;
    height:80px;
    left:0;
    position:absolute;
    top:0;
    width:95%;
    z-index:500;
}
.teaser:hover * {
    color: #ffffff;
}
span.linkDescription {
    display:block;
    position:absolute;
    text-indent:-3000px;
    z-index:-1;
}
/* drop land */
.dropDown {
    background:transparent url(../img/land_back.gif) no-repeat scroll 100% 6px;
    float:left;
    height:30px;
    padding-left:20px;
    padding-top:5px;
    position:relative;
    width:190px;
    font-size: 11px;
    z-index:1000;
    margin-top:7px;
}
.dropDown ul {
    position: absolute;
    height:0px;
    overflow: hidden;
    left: 2px;
    padding-top: 19px;
    cursor:pointer;
}
.dropDown ul:hover,
.dropDown ul.dateHover,
.dropDown ul.typeHover,
.dropDown ul.destinationHover {
    height:400px;
    overflow:auto;
    overflow-x:hidden;
}
.dropDown ul li {
    background-color:#EFEFEF;
    margin-left:7px;
    padding-bottom:3px;
    padding-left:10px;
    padding-top:3px;
    width:185px;
}
.dropDown ul li.active span {
    background:transparent url(../img/oval_orange_right.png) no-repeat scroll 100% 30%;
    height:20px;
    margin-left:-3px;
    padding:1px 8px 2px 3px;
}
.dropDown ul li.active {
    position: absolute;
    top: 0;
    left:0;
    margin-left:0;
    padding-top:1px;
    background:transparent url(../img/oval_orange_left.png) no-repeat scroll 0 0;
    width:100%;
    height: 20px;
    display: block;
}
.dropDown ul li.active a {
    color: #ffffff;
}
.dropDown ul li a {
    color:#47484D;
}
.dropDown ul li:hover {
    background-color:#C8C9CD;
}
.dropDown ul li.active:hover {
    background-color: transparent;
}
/* 123 */
.slidnavi {
    background:transparent url(../img/beam.gif) no-repeat scroll 0 0;
    float:left;
    height:41px;
    margin:0 15px 0 -3px;
    padding:12px 10px 2px 0;
    width:914px;
    display: inline;

}
.slidnavi a {
    margin: 0 0 0 5px;
    padding: 0 0 0 0;
    text-decoration: none;
    color:#474C54;
}
.slidnavi a:hover {
    color:#FF9713;
}
.slidnavi .slideNaviAktiv, .slidnavi a:hover.slideNaviAktiv {
    margin: 0 0 0 5px;
    color:#FF9713;
    text-decoration: none;
    cursor: default;
}
/* overlay */
#overlay {
    width: 820px;
    float:left;
    background-color: #ffffff;
    padding: 20px;
    position:relative;
}
#overlay p.pic {
    text-align: center;
    float:left;
    margin-bottom: 60px;
    width:100%
}
#overlay h2 {
    margin-bottom: -30px;
}
#overlay .colors {
    background:#EEEEF0 none repeat scroll 0 0;
    bottom:0;
    height:55px;
    left:0;
    padding:3px 20px 12px 18px;
    position:absolute;
    width:822px;
}
#overlay .colors p {
    margin:10px 15px 0 0;
    display:block;
    margin:10px 15px 0 0;
    position:relative;
}
#overlay .colors p.lft {
    height:50px;
    overflow:hidden;
    width:550px;
}
#overlay .colors .info {
    margin:10px 10px 0 0;
}
#overlay .colors  a {
    color:#474C54 !important;
    float:left;
    font-weight:normal !important;
}
#overlay .colors img {
    border:1px solid #D6D7D8;
    margin-right:2px;
}
#overlay .colors img:hover {
    border:1px solid #FF9713;
}
#overlay .colors .prodcols {
    margin-top:20px;
}
#overlay .colors .choose {
    margin:0 10px 0 0;
}
#content .faqBigShad {
    background:transparent url(../img/prodTeaserBig.jpg) no-repeat scroll 50% 0;
    margin-left:-14px;
    margin-top:-10px;
    padding-left:12px;
    padding-top:6px;
    width:925px;
    float:left;
    position:relative;
    padding-bottom: 85px;
    margin-bottom:23px;
}
#content .faqBig {
    width: 907px;
    border: 1px solid #ffffff;
    position:relative;
    float:left;
}

#content .guaranteeBox {
    float:left;
    width:680px;
    margin-right: 10px;
    padding-bottom:30px;
}
#content #guarantee { 
     background:transparent url(../img/bg_konTop.png) no-repeat scroll 0 0;
     float:left;
     padding:17px;
     width:646px;
}
#content #guarantee h1 { 
    font-size:12px;
    font-weight:bold;
}
#content #guarantee p { 
    margin-bottom: 20px;
}
#content #guarantee form input{ 
    font-size: 11px;
    padding:1px;
    margin-bottom:5px;
}
#content #guarantee form .FieldRequired { 
    border: 1px solid #b2b2b2;
    width: 350px;
    margin-bottom:6px;
}
#content #guarantee form .validationError { 
    border-color: #ff0000;
}
/* table compare */
#vergleich {
    width: 903px;
}
#vergleich h2.headline {
    width: 225px; float:left;
}
.compPop {
    margin-bottom: 17px;
    float:left;
}
.compPop table a {
    font-weight: normal;
    margin-left:-10px;
    margin-right:5px;
}
.compPop table {
    text-align:left;
    border-bottom: 1px solid #cccccc;
    border-top: 1px solid #cccccc;
    width: 900px;
}
.compPop table td, .compPop table th {
    width: 191px!important;
    text-align:left;
}
.compPop table .center {
    text-align:center;
}
.compPop table .gray {
    background-color: #f0f0f0;
}
.compPop table .bg{
    background: url(../img/bg_table.jpg) repeat-x 0% 0%;
}
.compPop table th {
    padding: 5px 17px;
}
.compPop table td {
    padding: 2px 17px!important;
}
.compPop table .brdLft {
    border-left: 1px solid #cccccc;
}
.compPop table .brdRgt {
    border-left: 1px solid #cccccc;
    border-right: 1px solid #cccccc;
}
.prodComp {
    width: 191px;
    padding: 17px;
    float: left;
}
.prodComp select {
    width: 191px;
    margin-bottom: 10px;
}
.prodComp p, .prodComp ul {
    padding-bottom: 10px;
}
.prodComp ul li {
    background:transparent url(../img/bullet.jpg) no-repeat scroll 0 7px;
    padding:0 0 0 10px;
}
#content .myaccountbox {
    float:left;
    width:900px;
    margin-right: 10px;
    padding-bottom:30px;
}
#content #myaccount { 
     background:transparent url(../img/bg_accTop.png) no-repeat scroll 0 0;
     float:left;
     padding:17px;
     width:866px;
}
#content #myaccountend {
    background:transparent url(../img/bg_accBtm.png) no-repeat scroll 0 100%;
    float:left;
    width:900px;
    height:22px;
    margin-bottom:20px;
}
#content #myaccount h1 { 
    font-size:12px;
    font-weight:bold;
}
#content #myaccount p { 
    margin-bottom: 20px;
}
#content #myaccount form { 
    float: left;
    width: 566px;
    padding-right: 150px;
    margin-bottom:20px;
}
#content #myaccount form label { 
    width: 210px;
    float:left;
}
#content #myaccount form select { 
    width: 352px!important;
    font-size: 11px;
    padding:1px;
    margin-bottom:5px;
}
#content #myaccount form input, form input, form select, form textarea { 
    font-size: 11px;
    padding:1px;
    margin-bottom:5px;
    font-family: Arial,Verdana,Helvetica,sans-serif;
}
#content #myaccount form textarea{ 
    height:100px;
    padding:1px;
    margin-bottom:5px;
}
#content #myaccount form .FieldRequired { 
    border: 1px solid #b2b2b2;
    width: 348px;
    margin-bottom:6px;
}
#content #myaccount form .FieldRequiredCalendar { 
    border: 1px solid #b2b2b2;
    width: 328px;
    margin-right:6px;
    margin-top:25px;
    margin-bottom:6px;
}
#content #myaccount form .FieldRequiredHint {
    font-size: 9px;
}

#content #myaccount form .FieldRequiredNoOutline {
    border: 0px solid #b2b2b2; 
    width: 348px;
    margin-bottom:6px;
}
#content #myaccount form .FieldRequiredSmall { 
    border: 1px solid #b2b2b2;
    width: 48px;
    margin-bottom:6px;
    margin-left:5px;
}
#content #myaccount form .FieldRequiredWide { 
    border: 1px solid #b2b2b2;
    width: 291px;
    margin-bottom:6px;
}

#content #myaccount form .radio{ 
    width: 350px;
    margin-bottom:6px;
    float:left;
}
#content #myaccount form .radio input { 
    margin-bottom:6px;
    float:left;
}
#content #myaccount form .radio label { 
    margin-bottom:6px;
    float:left;
    width:150px;
}
#content #myaccount form .check { 
    float: left;
    margin: 20px 0px;
    width: 500px;
}
#content #myaccount form .check input { 
    float: left;
}
#content #myaccount form .error { 
    color: #ff0000;
    margin-left:210px;
    margin-bottom:15px;
}
#content #myaccount form .validationError { 
    border-color: #ff0000;
}
#iframe {
    width:900px;
    margin-top: 50px;
    padding-bottom: 25px;
}
#iframe iframe {
    width: 500px;
    height: 200px;
    border: none;
    overflow:auto;
}
#content .faqBigShad {
    background:transparent url(../img/prodTeaserBig.jpg) no-repeat scroll 50% 0;
    margin-left:-14px;
    margin-top:-10px;
    padding-left:12px;
    padding-top:6px;
    width:925px;
    float:left;
    position:relative;
    padding-bottom: 85px;
    margin-bottom:23px;
}
#content .faqBig {
    width: 907px;
    border: 1px solid #ffffff;
    position:relative;
    float:left;
}
#content .faqBig .header {
    padding-top:15px;
}
#content .faqBig table {
    float:left;
}
#content .faqBig .compBig {
    margin:0 16px 0 17px;
}
#content .faqBig .compBig .download {
    margin-top: 20px;
    clear: both;
    border-bottom:1px solid #DCDCDC;
    float:left;
    width:875px;
}
#content .faqBig .compBig .download ul {
    background: none;
    margin-bottom: 5px;
    width:100%; 
}
#content .faqBig .compBig .download ul li {
    padding: 0;
    clear:both;
    background:transparent url(../img/bullet.jpg) no-repeat scroll 0 7px;
    font-weight:normal;
    padding:0 0 0 10px;
}
#content .faqBig .compBig .download ul li ul li {
    background:transparent url(../img/strich.gif) no-repeat scroll 0 6px;
    font-weight:normal;
    list-style:none;
    margin-left:15px;
    padding:0 0 0 10px;
}
#content .faqBig .compBig h2 {
    margin: 15px 0px 0px 0px;
    font-size:12px;
    font-weight:bold;
}
#content .faqBig .compBig .FieldRequired, #content .faqBig .comp .FieldRequired {
    width:180px;
    margin-bottom: 5px;
}
#content .faqBig .compBig select.FieldRequired, #content .faqBig .comp select.FieldRequired {
    color: #474C54;
    font-size: 12px;
    font-family: Arial,Verdana,Helvetica,sans-serif;
    line-height: 1.5;
    font-weight: normal;
}
#content .faqBig .comp {
    float:left;
    margin:0 16px 0 17px;
    width:420px;
}
#content .faqBig .header h1 {
    margin: 0px 16px 10px 17px;
    font-size:14px;
    font-weight:bold;
}
#content .faqBig .comp h2 {
    width: 410px;
    margin: 0px 0px 0px 0px;
    float:left;
    font-size:12px;
    font-weight:bold;
}
#content .faqBig .header p {
    margin: 0px 16px 0px 17px;
}
#content .faqBig .comp .rich-tree-node-text {
    white-space: normal;
}
#content .faqBig .comp .rich-tree-h-ic-img, #content .faqBig .comp .rich-tree-node-handleicon-collapsed, #content .faqBig .comp .rich-tree-node-handleicon-expanded, #content .faqBig .comp .rich-tree-node-icon-leaf {
    width: 26px;
    height: 9px;
    display: inline;
    vertical-align: top;
}
#content .faqBig .comp .rich-tree-h-ic-img img {
    margin-top: 5px;
}
#content .faqBig .comp .rich-tree-node-handleicon {
    width: 0px;
    padding: 0px;
}
#content #prodOver .contextColumn {
    width:238px;
    float:right;
}
#content #prodOver #pressReleaseList {
    float: left; 
    padding-bottom: 20px;
    padding-right: 17px;
    position: relative;
    width: 675px;
}
#content #prodOver #pressReleaseList h1 { 
    font-size:19px;
    font-weight:normal;
    float: left;
}
#content #prodOver #pressReleaseList .pressReleaseListContent { 
    float: left;
}
#content #prodOver #pressReleaseList .pressReleaseListContent .newsEntry { 
    float: left;
    width: 675px;
    padding-bottom: 20px;
    position: relative;
}
#content #prodOver #pressReleaseList .pressReleaseListContent .newsEntryText { 
    float: right;
    position:relative;
    width: 545px;
}
#content #prodOver #pressReleaseList .pressReleaseListContent .newsEntry .newsEntryImage {
    float: left;
    left:0;
    width: 130px;
}
#content #prodOver #pressReleaseList .pressReleaseListContent .newsEntry span { 
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 50%;
    padding-left: 12px;
}
#content #prodOver #pressReleaseList .pressReleaseListContent .newsEntry span:hover { 
    background:transparent url(../img/link_arrow_100black.gif) no-repeat scroll 0 50%;
}
#content #prodOver #pressReleaseList .pressReleaseListContent .newsEntry a.newsLnk { 
    display:block;
    height:100%;
    left:0;
    position:absolute;
    top:0;
    width:100%;
    z-index:500;
}
#content #prodSearch .searchProducts .sum a.newsLnk, #content #prodSearch .searchProducts .sumNoPic a.newsLnk { 
    display:block;
    height:85%;
    left:0;
    position:absolute;
    top:0;
    width:100%;
    z-index:500;
    background:url("../img/bg_transparent.gif") no-repeat scroll 0 0 transparent;
}
#content #prodOver #pressReleaseList .pressReleaseListContent .newsEntry h3 { 
    font-size: 12px;
    font-weight: bold;
    margin:0;
    float: none;
    width: 100%;
}
#content #prodOver #pressReleaseList .paging {
    float: right;
}
#content #prodOver #pressReleaseList .paging a {
    margin: 0 0 0 5px;
    padding: 0 0 0 0;
    text-decoration: none;
    color:#474C54;
}
#content #prodOver #pressReleaseList .paging a:hover {
    color:#FF9713;
}
#content #prodOver #pressReleaseList .paging .pageNaviAktiv, #content #prodOver #pressReleaseList .paging a:hover.pageNaviAktiv {
    margin: 0 0 0 5px;
    color:#FF9713;
    text-decoration: none;
    cursor: default;
}

/* ELA CategoryTwo */
#content .prodThreeColsSh h3 {
    margin-left: 10px;
}
.jcarousel-skin-tango ul li {
    background-color: #ffffff;
    display:block;
    position:relative;
}
.jcarousel-skin-tango ul li h3 {
    margin:25px 0px 0px 10px!important;
}
.jcarousel-skin-tango ul li img {
    margin:15px 12px 10px 0 !important;
}
.jcarousel-skin-tango li {
    margin-top: -15px;
}
#content .prodThreeColsText .prodThreeColsNews {
    background: #FFFFFF url(../img/white.jpg)!important;
    margin:0px 0px 10px 15px;
    float:left;
    position:relative;
    width: 880px;
}
#content .prodThreeColsText .prodThreeColsNews img {
    float: left;
}
#content .prodThreeColsText .prodThreeColsNews h3 {
    float:none;
    font-size:12px;
    font-weight:bold;
    margin:5px 0px 0px 0px;
    width:auto;
}
#content .prodThreeColsText .prodThreeColsNews p {
    padding-right: 50px;
}
.brdBtm {
    border-bottom:1px solid #DCDCDC;
    margin:0px 0px 10px 15px;
    float:left;
    width: 95%;
}
#content .prodThreeColsText .prodThreeColsNews .newsEntryText { 
    float: right;
    position:relative;
    width: 730px;
    padding-top:10px;
    padding-bottom:10px;
}
#content .prodThreeColsText .prodThreeColsNews .newsEntryImage {
    float: left;
    left:0;
    width: 130px;
    padding-left: 20px;
    padding-top:10px;
    padding-bottom:10px;
}
#content .prodThreeColsText .prodThreeColsNews span { 
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 50%;
    padding-left: 12px;
}
#content .prodThreeColsText .prodThreeColsNews span:hover { 
    background:transparent url(../img/link_arrow_100black.gif) no-repeat scroll 0 50%;
}
#content .prodThreeColsText .prodThreeColsNews a.newsLnk { 
    display:block;
    height:100%;
    left:0;
    position:absolute;
    top:0;
    width:100%;
    z-index:500;
}
#content .prodThreeColsText .prodThreeColsNews h3 { 
    font-size: 12px;
    font-weight: bold;
    margin:0;
    float: none;
    width: 100%;
}
.findeisenTest {
    position: relative;
    left: -45px;
    height: 390px;
}
.AlphaImagePositionFix {
}
#messageline {
    width: 894px;
    float: left;
    padding: 15px 0px 15px 15px;
    margin-right: 17px;
    font-size: 12px;
    color: #ffffff;
    font-weight: bold;
}
.messageLineError {
    background-color: #be0f1e;
}
.messageLineInfo {
    background-color: #67b437;
}
#content #errorPage {
    margin: 50px 0px 50px 20px;
}
#content #errorPage h1 {
    margin-bottom: 10px;
}

.rich-tree-node-text {
    white-space:normal!important;
    width:400px!important;
}
#content #myaccount .hint { 
    margin-top:-2px;
    float:left;
}
.iePos img {
    margin-left: 45.5%!important;
}
/* PRINT STUFF \*/
@media print {
html {
    margin: 0;
    padding: 0;
    width: 21cm;
}
body {
    color: #000!important;
    background-color: white!important;
    background-image: none!important;
    overflow:visible;
}
h1, h2, h3, h4, h5, h6 {
  page-break-after: avoid!important;
}
#header {
    height: 70px;
}
#footer, #footer .teaser, #content #linknavi, #content .prodThreeColsText, #content .prodThreeColsSh, #content_area, #content .prodTeaserBig .linkbox, #content .prodTeaserBig .comp, #content .prodThreeColsText .prodThreeColsNews, #content .contactBox, #content .prodTeaserBig, #content .prodTeaserBigShad, #content, #content #prodOver #lftSide, #content #prodOver .contentText {
    float: none!important;
    clear: both!important;
}
/* Fuer die Druckausgabe abgeschaltet */
.dropDown, ul#Navigation, ul#metanavi, a.btn, #footer_copy a, #search, #footerlogos,#content #linknaviBtm, #breadcrumbs span.tell, #content #prodOver #rgtSide, .slidnavi, #content #prodOver #category, #vergleich h2, #content #linknavi, #content #prodSearch .searchProducts .sum a.newsLnk, #content #prodSearch .searchProducts .sumNoPic a.newsLnk {
    display: none!important;
}
/* Linksbuendige Ausrichtung */
#logo, #description, .one, #footer_copy, #footer_copy p, #content, #header, #footer, #contentStart, #content, #content_area, #content .prodThreeColsText, #content .prodThreeColsSh, #content #linknavi, #content #linknaviTop, #content .prodThreeColsText .text, #content .prodTeaserBigShad, #content .prodTeaserBig li, #content .prodTeaserBig .sumLong, #content .prodTeaserBig .download, #content .prodTeaserBig .linkbox h3, #content .prodTeaserBig .comp, #content #prodOver .oneColTop, #content #contact {
    margin-left: 0px!important;
    padding-left: 0px!important;
}
#content .prodTeaserBig .sum, #content .prodTeaserBig table.all {
    margin-left: 0px!important;
}
#content .prodTeaserBig .linkbox {
    margin:10px 0px 10px 0px!important;
    padding:20px 0px 20px 0px!important;
    height:auto!important;
}
#content .prodTeaserBig .comp {
    padding-top: 20px;
}
#facebox {
    left: 0px!important;
    top: 0px!important;
    margin:0px!important;
    padding:0px!important;
}
/* Weiten f?r A4 anpassen */
#content, #content .prodThreeColsText, #footer, #content .prodThreeColsText .prodThreeColsNews, #content .prodTeaserBig .sum, #content .prodTeaserBig .sumLong, #content .prodTeaserBig .download, #content .prodTeaserBig table.all, #content .prodTeaserBigShad .colors, #overlay, #overlay .colors, .compPop table, #content .prodTeaserBig {
    width: 650px;
}
#content .prodThreeColsSh {
    width: 608px;
    height: 145px;
    overflow: hidden;
}
#content .prodTeaserBig .sum ul.list {
    margin-top: 20px;
}
.download a, #content #prodOver .contentText .download a, #content #prodOver .contentTwoCol .download a, .download a span, #content #prodOver .contentText .download a span, #content #prodOver .contentTwoCol .download a span {
    margin-left: 0px;
    padding-left: 0px;
    color:#FF9713!important;
}
#footer ul {
    margin-bottom: 20px;
}
#footer ul.rght {
    margin-right: 0px!important;
    float:left!important;
}
#footer .teaser {
    height: 70px;
}
#content_area {
     overflow: inherit!important;
}
}
/* end media print \

a.btnred { background: url('/img/btn_submit_l.png') no-repeat scroll 0pt 0pt transparent ! important; border: 0pt none; color: rgb(255, 255, 255) ! important; cursor: pointer ! important; float: left; font-size: 12px; font-weight: bold ! important; height: 40px; margin: 5px 0pt; padding: 0pt 0pt 0pt 20px ! important; white-space: nowrap; overflow: visible; position: relative; width: auto; }
a.btnred span { background: url('/img/btn_submit_r.png') no-repeat scroll 100% 0pt transparent; border: 0pt none; color: rgb(255, 255, 255) ! important; display: inline-block; overflow: hidden; height: 40px; padding: 11px 20px 0pt 0px ! important; position: relative; }
a.btnred:hover { background: url('/img/btn_submit_l_h.png') no-repeat scroll 0pt 0pt transparent ! important; }
a.btnred:hover span { background: url('/img/btn_submit_r_h.png') no-repeat scroll 100% 0pt transparent; }
*/
a.btnred {
    background: url("../img/download_front.gif") no-repeat scroll 0 0 transparent;
    border: 0 none;
    color: #FFFFFF !important;
    cursor: pointer;
    display: block;
    float: left;
    font-size: 12px;
    height: 30px;
    margin: 5px 0;
    padding: 0 0 0 7px;
    position: relative;
}
a.btnred span {
    background: url("../img/download_back.gif") no-repeat scroll 100% 0 transparent;
    border: 0 none;
    color: #FFFFFF !important;
    display: inline-block;
    height: 30px;
    overflow: hidden;
    padding: 4px 15px 0 5px;
    position: relative;
}
a.btnred:hover {
}

a.btnred:hover span  {
}
    
    
#sitemapcontent .productlist {clear:both; float: left; margin-top: 10px; margin-bottom: 60px;}
#sitemapcontent h1 {font-size: 12px;line-height: 1.5;margin-bottom: 7px;}
#lotteryForm { font-size: 16px; width: 500px; }
.LotteryInputText { border-width: 0px 0px thin ! important; border-color: -moz-use-text-color -moz-use-text-color rgb(71, 76, 84) ! important; background-color: transparent ! important; }
#lotteryForm input.rich-calendar-input{border: none; border-style: none; background-color: transparent !important;float: left;width: 328px;}
span .rich-calendar-button {
    background-color: #F28700;
    cursor: pointer;
    padding: 0 9px 0 3px;
    margin: 0 -20px 0 0;
    position: relative;
    vertical-align: middle;
}

.lottery #lotteryForm input{color: #474C54;font-size: 16px; margin-top:-3px;}
.divfield { width:100%; border-bottom: 1px solid #474C54; position:relative; display:block; margin: 0 0 15px 0; height:15px; }
.divlogo {     position: absolute;
    top: 750px;
    width: 91%; display:block; margin: 70px 0 15px 0; }
.lotteryradiobutton {float: left;}
.lotteryradiobutton label { margin: 0 15px 0 3px; }
.sitemapProductList {
    margin: 0 0 0 5px;
    text-decoration: none;
    cursor: default;
    display:block;
}

.sitemapProductList a {
    background:transparent url(../img/link_arrow_80black.gif) no-repeat scroll 0 50%;
    display:block;
    position:relative;
    font-weight:normal;
    padding-left:12px;
}
#lotteryIframe1 #messageline .messageLineError{
    width: 894px;
    float: left;
    padding: 15px 0px 15px 15px;
    margin-right: 17px;
    font-size: 12px;
    color: #ffffff;
    font-weight: bold;
    background-color: #be0f1e;
}

#content .prodTeaserBig .productpromotiontable {
    border-spacing:10px;
}
#content .prodTeaserBig .productpromotiontable td {
    padding: 0px 5px !important;
}