/*** Main CSS Style ***/

	a{
		outline: none;
	}

	#labs_container{
		color: #333;
	}

	#labs_container h1{
		color: #333;
		clear: both;
		display: block;
		font-size: 20px;
		text-shadow: 0 1px 4px #ddd;
	}
	
	#labs_container .bPageBlock, #labs_container .bPageBlock .pbBody {
		background: none;
		border: 0;
	}
	
	#labs_container .bPageBlock .pbFooter, .bWizardBlock .pbFooter {
		display: none;
	}



/*** Overlay ***/
	.overlay{

		/* must be initially hidden */
		display:none;
		
		/* place overlay on top of other elements */
		z-index:10000;
		
		/* styling */
		background:rgba(255, 255, 255, 0.97);
		padding: 20px;
		width:675px;	
		min-height:100px;
		
		/* CSS3 styling for latest browsers */
		-moz-box-shadow:0 0 90px 5px #000;
		-moz-border-radius: 10px;
		
		-webkit-box-shadow: 0 0 90px #000;
		-webkit-border-radius: 10px;
	}	

	.overlay .close {
		background: url({!$Resource.lists_close}) no-repeat;
		position:absolute;
		right:-15px;
		top:-15px;
		cursor:pointer;
		height:29px;
		width:29px;
	}
	
	.prompt{
		color: #555;
		font-size: 14px;
		font-weight: bold;
		display: block;
		float: left;
		padding-top: 14px;
	}
	
	#topPickList{
		float: right;
		padding-left: 10px;
	}
	
	
	.overlay textarea{
		width: 100%;
	}



/*** Survey List ***/


	#labs_container .survey_preview{
		display: block;
		float: left;
		padding: 10px 10px 40px 10px;
		margin: 4px;
		position: relative;
		background: white;
		border: 1px solid #ccc;
		width: 200px;
		min-height: 100px;
		box-shadow: 0px 2px 4px #ccc;
		border-radius: 5px;
		-moz-box-shadow: 0px 2px 4px #ccc;
		-moz-border-radius: 5px;
		-webkit-box-shadow: 0px 2px 4px #ccc;
		-webkit-border-radius: 5px;
	}
	
		#labs_container .survey_preview h2 a{
			clear: both;
			color: rgb(23, 151, 192);
			display: block;
			font-size: 16px;
			text-decoration: none;
			-moz-text-overflow: ellipsis-word;
			width: 100%;
		}
		
		#labs_container .survey_preview h2 a:hover{
			text-decoration: underline;
		}
		
		#labs_container .survey_preview .footer{
			bottom: 10px;
			position: absolute;
		}
		
		
/*** Survey Page ***/

	#questionList{
		margin: 10px 0px 20px 200px;
		border:1px solid #ccc;
		-moz-box-shadow: 0px 2px 4px #ccc;
		-moz-border-radius: 5px;
	}
	
	#questionList .pbBody{
		margin: 0;
	}
	
	.question{
		min-height:180px;
		padding:10px;
		background:white;
		margin: 4px;
		position: relative;
	}
	
	.question h1 a{
		text-decoration: none;
	}
	
	.question_menu{
		background:#f9f9f9;
		border: 3px solid #ccc;
		border-right: 0;
		left:-228px;
		padding:10px;
		position:absolute;
		width:200px;
		-moz-border-radius-topleft: 5px;
		-moz-border-radius-bottomleft: 5px;
	}
	
	.results{
		position: absolute;
		right: -410px;
		top: 10px;
		display: none;
	}
	
	span[id*="surveyPreview"]  {
		border:1px solid #ccc;
		display:block;
		margin:0 auto;
		width:80%;
		-moz-border-radius: 10px;
	}