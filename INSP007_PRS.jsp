<!--
**********************************************************************
* Copyright @ OST Group INC
* File Name    	 :
* Create Date 	 : 9/20/2024
* Create User 	 : Jimmy Choi <OST Group INC>
* Create Version : 2.0
* Update Date    :
* Update User 	 :
* Update Version : 2.0
* Description    :
**********************************************************************
-->
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="/OST_lib/title.ost"%>
    <%@ include file="/OST_lib/ost_common.ost"%>
    <%@ include file="/OST_lib/uploader.ost"%>
    <!-- For QR Scanner -->
    <script src="/OST_lib/html5-qrcode.min.js" type="text/javascript"></script>

    <script>
        var okng_cnt = 0;
        var range_cnt = 0;
        var total_cnt = 0;
        let arrInspCd = [];
        let arrCheckType = [];
        let arrCriteria = [];
        let arrValueSTD = [];
        let arrStdValue = [];
        let arrCheckValue = [];
        let arrObjectName = [];
        let arrObjectIndex = [];
        let arrResult = [];
        let arrRemark = [];
        let arrImgPath = [];
        var InspDocNo = '';
        var img_cnt = 0;
        var imgs = [];
        var curr_img_index = 0;
        var imgId;

        $(document).ready(function() {
            //BootstrapTable Grid Event
            $('#grid tbody').on('click', 'tr', function() {
                $("tr").removeClass('selected');
                if ($(this).hasClass('selected')) {
                    $(this).removeClass('selected');
                } else {
                    $(this).addClass('selected');
                }
                //Grid Cell Click Event
                //InspDocNo = $('td', this).eq(0).text();
                //fn_search_detail();
                //ComboSetValue('#cb_shop', $('td', this).eq(1).text());
                //console.log('Order no : ' + InspDocNo);
            });

            document.getElementById("I_LINE_CD").disabled = true;
            document.getElementById("I_LINE_NM").disabled = true;
            document.getElementById("I_PART_NO").disabled = true;
            document.getElementById("I_PROD_LOT_NO").disabled = true;

            //Inspectio Type Changed Event
            $('#cb_insp_type').on('change changed.bs.select', function() {
              if (!this.value) { return; }
              fn_load_check_list(this.value);
            });

            //Inspectio Type Changed Event
            $('#cb_part_no').on('change', function() {
              //alert( this.value );
              fn_load_check_list_part(this.value);
            });



            //For QR Scanner
            function docReady(fn) {
                // see if DOM is already available
                if (document.readyState === "complete" ||
                    document.readyState === "interactive") {
                    // call on next available tick
                    setTimeout(fn, 1);
                } else {
                    document.addEventListener("DOMContentLoaded", fn);
                }
            }
            var resultContainer = document.getElementById('qr-reader-results');
            var lastResult, countResults = 0;

            function onScanSuccess(decodedText, decodedResult) {
                if (decodedText !== lastResult) {
                    ++countResults;
                    //lastResult = decodedText;
                    // Handle on success condition with the decoded message.
                    console.log(`Scan result ${decodedText}`, decodedResult);
                    //alert(decodedText);
                    //Stop After Scanned
                    //html5QrcodeScanner.clear();
                    //Pause After Scanned
                    let shouldPauseVideo = true;
                    let showPausedBanner = false;
                    html5QrcodeScanner.pause(shouldPauseVideo, showPausedBanner);
                    //fn_setCombo();
                    fn_search(decodedText);
                }
            }

            var html5QrcodeScanner = new Html5QrcodeScanner(
                "qr-reader", {
                    fps: 10,
                    qrbox: 250,
                    rememberLastUsedCamera: true,
                    facingMode: {
                        exact: "environment"
                    },
                    // Only support camera scan type.
                    supportedScanTypes: [Html5QrcodeScanType.SCAN_TYPE_CAMERA]
                });
            html5QrcodeScanner.render(onScanSuccess);
        });
/*
        function fn_getUploadPath(header, path, id) {
            curr_img_path_index = id;
            fn_upload(header, path, "onSuccessUploadResult");
        }

        function onSuccessUploadResult(data) {
          var objImgPath = 'chk_okng_path_' + curr_img_path_index;
          document.getElementById(objImgPath).value = data;

            //showlog(data);
            //document.getElementById("I_USER_PIC").value = data;
        }
*/
        function fn_getUploadPath(header, path) {
            imgId = path;
            var temp_file_name = InspDocNo + "-" + path + ".jpg";
            var temp_path = "inspection/"+$('#cb_insp_type').val();
            fn_uploadGuide(header, temp_path, temp_file_name,"onSuccessUploadResult");
        }

        function onSuccessUploadResult(data) {

          document.getElementById(imgId).value = data;
            showlog(data);
        }


        function fn_page_init() {
            if (getCookie("comp_cd") == "" || getCookie("user_cd") == "") {
                window.location.href = "/";
                return;
            }
            fn_menu_load();
            fn_menu_path_load();
            fn_notice_load();
            fn_user_info_load();

            $("#div_part_no").hide();
        }

        function fn_clear() {
            //LoadCheckImage();
            okng_cnt = 0;
            range_cnt = 0;
            total_cnt = 0;
            InspDocNo = '';

            arrInspCd.length = 0;
            arrCheckType.length = 0;
            arrCriteria.length = 0;
            arrValueSTD.length = 0;
            arrStdValue.length = 0;
            arrCheckValue.length = 0;
            arrObjectName.length = 0;
            arrObjectIndex.length = 0;
            arrResult.length = 0;
            arrRemark.length = 0;

            fn_clear_checksheet();

            ShowSystemAlert('[INFO]', ' System Input Fields Cleared..', '2000');
        }

        function fn_clear_checksheet() {
            okng_cnt = 0;
            range_cnt = 0;
            total_cnt = 0;
            document.getElementById("I_CHECK_IMG").src = "/img/blank2.jpg";
            for(var i=0;i<20;i++){
                document.getElementById("chk_okng_criteria_" + (i+1)).value = "";
                document.getElementById("chk_okng_std_" + (i+1)).value = "";
                $('#div_okng_' + (i+1)).hide();
                document.getElementById("chk_range_criteria_" + (i+1)).value = "";
                document.getElementById("chk_range_std_" + (i+1)).value = "";
                $('#div_range_' + (i+1)).hide();
            }
        }

        function fn_search(pLINE_CD) {
            var usercd = getCookie("user_cd");
            if (usercd == null || usercd == "" || usercd == undefined) {
                window.location.href = "/login.jsp";
            }

            document.getElementById("I_LINE_CD").value = pLINE_CD;

            fn_load_insp_type_list(pLINE_CD);
            fn_load_part_no_list(pLINE_CD);
            fn_set_fixed_insp_type();


        }

        function fn_set_fixed_insp_type() {
            $('#cb_insp_type').empty();
            $('#cb_insp_type').append('<option value="FML_LIST">FML_LIST</option>');
            $("#cb_insp_type").selectpicker("refresh");
            $('#cb_insp_type').selectpicker('val', 'FML_LIST');
            $('#cb_insp_type').trigger('change');
        }

        function fn_load_insp_type_list(pLINE_CD) {
            var paramObj = {};
            paramObj["SQL"] = "PKG_INSP_COMMON_NEW.INSP_GROUP_PROD";
            paramObj["I_LINE_CD"] = pLINE_CD;
            onSelectDataTable(paramObj, "onSuccessSelectResult", true);
        }

        function fn_load_part_no_list(pLINE_CD) {
            var paramObj = {};
            paramObj["SQL"] = "PKG_INSP007_PRS.PART_NO_LIST";
            paramObj["I_LINE_CD"] = pLINE_CD;
            onSelect(paramObj, "onSuccessPartNoList", true);
        }

        function onSuccessPartNoList(data) {
            var result = data.result;

            if (!result || result.length === 0) {
                document.getElementById("I_PART_NO").value = "";
                document.getElementById("I_PROD_LOT_NO").value = "";
                return;
            }

            var partNoList = [];
            var prodLotNoList = [];
            for (var i = 0; i < result.length; i++) {
                var partNo = result[i].part_no || result[i].code || result[i].name;
                if (partNo) {
                    partNoList.push(partNo);
                }

                var prodLotNo = result[i].prod_lot_no || result[i].prodLotNo;
                if (prodLotNo) {
                    prodLotNoList.push(prodLotNo);
                }
            }

            document.getElementById("I_PART_NO").value = partNoList.join(", ");
            document.getElementById("I_PROD_LOT_NO").value = prodLotNoList.join(", ");
        }

        function onSuccessSelectResult(data) {

            var result_json = data.data;

            if (!result_json || result_json.length === 0) {
                document.getElementById("I_LINE_NM").value = "";
                return;
            }

            document.getElementById("I_LINE_NM").value = result_json[0].line_nm;
        }

        function fn_load_check_list(pINSP_TYPE) {
            var usercd = getCookie("user_cd");
            if (usercd == null || usercd == "" || usercd == undefined) {
                window.location.href = "/login.jsp";
            }

            if (pINSP_TYPE == "FML_LIST" || pINSP_TYPE == "QC_FML_CHECK" || pINSP_TYPE == "QC_DIMS_CHECK" || pINSP_TYPE == "MT_CO2_CHECK" ||pINSP_TYPE == "PRESS_FML_CHECK") {
                $("#div_part_no").show();
                fn_part_Combo();
            }

            else {
                $("#cb_part_no").empty();
                $("#div_part_no").hide();
                var paramObj = {};
                paramObj["SQL"] = "PKG_INSP_COMMON_NEW.LINE_CHECKLIST";
                paramObj["I_LINE_CD"] = document.getElementById("I_LINE_CD").value;
                paramObj["I_PART_NO"] = "";
                paramObj["I_INSP_CD"] = pINSP_TYPE;
                onSelectDataTable(paramObj, "onSuccessSelectCheckList", true);
            }
        }


//Currnt ending point

          function fn_get_fml_suffix(pFmlCode) {
              var fmlCode = (pFmlCode || '').toString().trim().toUpperCase();

              if (fmlCode === 'FIRST' || fmlCode === 'F' || fmlCode === '1') return 'F';
              if (fmlCode === 'SECOND' || fmlCode === 'S' || fmlCode === '2') return 'S';
              if (fmlCode === 'THIRD' || fmlCode === 'T' || fmlCode === '3') return 'T';

              if (fmlCode.length > 0) {
                  return fmlCode.charAt(0);
              }
              return '';
          }

          function fn_is_binary_std_value(pStdValue) {
            var value = (pStdValue || '').toString().trim().toUpperCase();
            return value == 'YES' || value == 'NO' || value == 'OK' || value == 'NG';
        }

        function fn_is_numeric_std_value(pStdValue) {
            var value = (pStdValue || '').toString().trim();
            if (value == '') {
                return false;
            }
            return !isNaN(Number(value));
        }

        function fn_set_binary_option_label(pIndex, pStdValue) {
            var value = (pStdValue || '').toString().trim().toUpperCase();
            var firstValue = (value == 'YES' || value == 'NO') ? 'YES' : 'OK';
            var secondValue = (firstValue == 'YES') ? 'NO' : 'NG';

            var firstInput = document.getElementById('chk_okng_ok_' + pIndex);
            var secondInput = document.getElementById('chk_okng_ng_' + pIndex);
            if (firstInput) { firstInput.value = firstValue; firstInput.checked = false; }
            if (secondInput) { secondInput.value = secondValue; secondInput.checked = false; }

            $("label[for='chk_okng_ok_" + pIndex + "']").text(firstValue);
            $("label[for='chk_okng_ng_" + pIndex + "']").text(secondValue);
          }

          function fn_load_check_list_part(pPART_NO) {
              var usercd = getCookie("user_cd");
              if (usercd == null || usercd == "" || usercd == undefined) {
                  window.location.href = "/login.jsp";
              }

              var lineCd = document.getElementById("I_LINE_CD").value;
              var rawPartNo = (document.getElementById("I_PART_NO").value || '').toString().trim();
              var partNo = rawPartNo.split(',')[0].trim();
              var fmlCd = fn_get_fml_suffix(pPART_NO);

              if (lineCd == "" || partNo == "" || fmlCd == "") {
                    alert("Part No/FML is not valid. Please re-check your selection.");
                    return;
                }

              var paramObj = {};
              paramObj["SQL"] = "PKG_INSP007_PRS.CHECK_LIST";
              paramObj["I_LINE_CD"] = lineCd;
              paramObj["I_PART_NO"] = partNo;
              paramObj["I_FML_CD"] = fmlCd;

              onSelectDataTable(paramObj, "onSuccessSelectCheckList", true);
          }

        function onSuccessSelectCheckList(data) {
            //var result = data.result;
            fn_clear();

            var result = data.data;

            for(var i=0; i<result.length; i++){
              var stdValue = (result[i].std_value || '').toString().trim();
              var criteria = result[i].insp_criteria || result[i].insp_nm || '';
              var inspCd = result[i].insp_cd || (i + 1).toString();
              var isBinary = fn_is_binary_std_value(stdValue);
              var isRange = stdValue.indexOf('~') != -1 || fn_is_numeric_std_value(stdValue);

              if(isBinary){
                $('#div_okng_' + (okng_cnt+1)).show();
                document.getElementById("chk_okng_criteria_" + (okng_cnt+1)).value = criteria;
                document.getElementById("chk_okng_std_" + (okng_cnt+1)).value = stdValue;
                fn_set_binary_option_label((okng_cnt+1), stdValue);
                arrInspCd.push(inspCd);
                arrCheckType.push('OKNG');
                arrCriteria.push(criteria);
                arrStdValue.push(stdValue);
                arrObjectName.push("chk_okng_value_" + (okng_cnt+1));
                arrObjectIndex.push((okng_cnt+1));
                okng_cnt+=1;
                total_cnt+=1;
              }
              else if(isRange){
                $('#div_range_' + (range_cnt+1)).show();
                document.getElementById("chk_range_criteria_" + (range_cnt+1)).value = criteria;
                document.getElementById("chk_range_std_" + (range_cnt+1)).value = stdValue;
                arrInspCd.push(inspCd);
                arrCheckType.push('RANGE');
                arrCriteria.push(criteria);
                arrStdValue.push(stdValue);
                arrObjectName.push("chk_range_value_" + (range_cnt+1));
                arrObjectIndex.push((range_cnt+1));
                range_cnt+=1;
                total_cnt+=1;
              }
            }

            img_cnt = (result.length > 0 && result[0].img_count) ? result[0].img_count : "0";

            if (img_cnt != "0") {
                fn_load_check_image();
            }
            else {
                document.getElementById("I_CHECK_IMG").src = "/img/blank2.jpg";
                document.getElementById("I_IMG_COUNT").value = "0 / 0";
            }
            fn_get_doc_no();
        }

        function fn_load_check_image() {
            document.getElementById("I_CHECK_IMG").src = "/img/blank2.jpg";
            document.getElementById("I_IMG_COUNT").value = "0 / 0";
            imgs.length = 0;

            var paramObj = {};
            paramObj["SQL"] = "PKG_INSP_COMMON_NEW.CHECKLIST_IMG";
            paramObj["I_LINE_CD"] = document.getElementById("I_LINE_CD").value;
            paramObj["I_INSP_CD_GRP"] = $("#cb_part_no").val();
            paramObj["I_INSP_TYPE"] = $("#cb_insp_type").val();
            onSelectDataTable(paramObj, "onSuccessSelectCheckImage", true);
        }

        function onSuccessSelectCheckImage(data) {
            var result = data.data;
            img_cnt = result.length;
            for (var i = 0; i < result.length; i++) {
                imgs.push(result[i].img_path);
            }
            curr_img_index = 0;
            document.getElementById("I_CHECK_IMG").src = imgs[curr_img_index];
            document.getElementById("I_IMG_COUNT").textContent = (curr_img_index+1) + " / " + img_cnt;
        }

        function fn_PrevImg() {
            if(curr_img_index > 0) {
                curr_img_index--;
                document.getElementById("I_CHECK_IMG").src = imgs[curr_img_index];
                document.getElementById("I_IMG_COUNT").textContent = (curr_img_index+1) + " / " + img_cnt;
            }
        }

        function fn_NextImg() {
            if(curr_img_index < img_cnt-1) {
                curr_img_index++;
                document.getElementById("I_CHECK_IMG").src = imgs[curr_img_index];
                document.getElementById("I_IMG_COUNT").textContent = (curr_img_index+1) + " / " + img_cnt;
            }
        }

        function fn_get_doc_no() {
            //Get INSP DOC
            var paramObj = {};
            paramObj["SQL"] = "PKG_INSP_COMMON_NEW.LINE_CHECKLIST_DOCNO";
            paramObj["I_LINE_CD"] = document.getElementById("I_LINE_CD").value;
            onSelect(paramObj, "onSuccessSelectDocNo", true);
        }

        function onSuccessSelectDocNo(data) {
            var result = data.result;
            InspDocNo = result[0].new_lot_var;
            //fn_db_save();
            //alert(InspDocNo);
        }

        function fn_save() {
            var usercd = getCookie("user_cd");
            if (usercd == null || usercd == "" || usercd == undefined) {
                window.location.href = "/login.jsp";
            }

            if ($("#cb_insp_type").val() == "PR_ATD_DAILY") {
                for(var i=1; i<= total_cnt; i++)
                {
                    if(arrStdValue[i-1].indexOf('~') != -1){
                        var img_check = document.getElementById("chk_range_path_" + arrObjectIndex[i-1]).value;
                        if (img_check == "") {
                            alert("Please check and upload the photo... ");
                            return;
                        }
                    }
                    else {
                        var img_check = document.getElementById("chk_okng_path_" + arrObjectIndex[i-1]).value;
                        if (img_check == "") {
                            alert("Please check and upload the photo... ");
                            return;
                        }
                    }
                }

            }

          //Reset Result Array
          arrResult = [];
          var result_code = "OK";
          var ng_criteria = "";
          //Do Loop for Check
          for(var i=1; i<=total_cnt; i++){
            //alert(arrCheckType[i-1] + '/' + arrStdValue[i-1]);

            if(arrCheckType[i-1] == 'RANGE'){
              //Range Check
              var stdText = (arrStdValue[i-1] || '').toString().trim();
              var std_values = stdText.split('~');
              var value_std = document.getElementById("chk_range_std_" + arrObjectIndex[i-1]).value;
              var check_value = document.getElementById(arrObjectName[i-1]).value;
              var remark_value = document.getElementById("chk_range_rmk_" + arrObjectIndex[i-1]).value;
              var imgpath_value = document.getElementById("chk_range_path_" + arrObjectIndex[i-1]).value;

              if(check_value == null || check_value == "")
              {
                alert ("Not all inspection results have been registered...\n\n Please check the list and input the result");
                return;
              }
              var isRangePass = false;
              if (stdText.indexOf('~') != -1 && std_values.length == 2) {
                isRangePass = (check_value*1 >= std_values[0]*1 && check_value*1 <= std_values[1]*1);
              }
              else if (fn_is_numeric_std_value(stdText)) {
                isRangePass = (check_value*1 == stdText*1);
              }

              if(isRangePass){
                document.getElementById("chk_range_criteria_" + arrObjectIndex[i-1]).style.color = 'blue';
                document.getElementById("chk_range_std_" + arrObjectIndex[i-1]).style.color = 'blue';
                document.getElementById("chk_range_value_" + arrObjectIndex[i-1]).style.color = 'blue';
                arrValueSTD.push(value_std);
                //arrCriteria.push(criteria);
                arrResult.push(check_value);
                arrRemark.push(remark_value);
                arrImgPath.push(imgpath_value);
              }else{
                document.getElementById("chk_range_criteria_" + arrObjectIndex[i-1]).style.color = 'red';
                document.getElementById("chk_range_std_" + arrObjectIndex[i-1]).style.color = 'red';
                document.getElementById("chk_range_value_" + arrObjectIndex[i-1]).style.color = 'red';
                arrValueSTD.push(value_std);
                //arrCriteria.push(criteria);
                arrResult.push(check_value);
                arrRemark.push(remark_value);
                arrImgPath.push(imgpath_value);
                result_code = "NG";
                ng_criteria = document.getElementById("chk_range_criteria_" + arrObjectIndex[i-1]).value
              }
              //arrResult.push('OK');
            }
            else{
              //OKNG Check
              var temp_obj = "input[name='chk_okng_value_" + arrObjectIndex[i-1] + "']:checked";
              var value_std = document.getElementById("chk_okng_std_" + arrObjectIndex[i-1]).value;
              if(!document.querySelector(temp_obj))
              {
                alert ("Not all inspection results have been registered...\n\n Please check the list and input the result");
                return;
              }
              var check_value = document.querySelector(temp_obj).value;
              var remark_value = document.getElementById("chk_okng_rmk_" + arrObjectIndex[i-1]).value;
              var imgpath_value = document.getElementById("chk_okng_path_" + arrObjectIndex[i-1]).value;

              var stdUpper = (value_std || '').toString().trim().toUpperCase();
              var checkUpper = (check_value || '').toString().trim().toUpperCase();
              var isOkNgPass = (checkUpper == stdUpper)
                  || (stdUpper == 'YES' && checkUpper == 'OK')
                  || (stdUpper == 'NO' && checkUpper == 'NG');

              if(isOkNgPass){
                //OK
                document.getElementById("chk_okng_criteria_" + arrObjectIndex[i-1]).style.color = 'blue';
                document.getElementById("chk_okng_std_" + arrObjectIndex[i-1]).style.color = 'blue';
                //document.getElementById("chk_range_value_" + arrObjectIndex[i-1]).style.color = 'blue';
                arrValueSTD.push(value_std);
                arrResult.push(check_value);
                arrRemark.push(remark_value);
                arrImgPath.push(imgpath_value);
                //alert('OK');
              }else{
                //NG
                document.getElementById("chk_okng_criteria_" + arrObjectIndex[i-1]).style.color = 'red';
                document.getElementById("chk_okng_std_" + arrObjectIndex[i-1]).style.color = 'red';
                //document.getElementById("chk_range_value_" + arrObjectIndex[i-1]).style.color = 'red';
                arrValueSTD.push(value_std);
                arrResult.push(check_value);
                arrRemark.push(remark_value);
                arrImgPath.push(imgpath_value);
                result_code = "NG";
                ng_criteria = document.getElementById("chk_okng_criteria_" + arrObjectIndex[i-1]).value;
              }
            }
          }

          var line_cd_arr = [];
          var insp_doc_no_arr = [];
          var insp_cd_arr = [];
          var insp_result_arr = [];
          var user_cd_arr = [];
          var rcv_dept_arr = [];
          var remark_arr = [];
          var insp_type_arr = [];
          var insp_criteria_arr = [];
          var value_std_arr = [];
          var part_no_arr = [];
          var img_path_arr = [];

          //DB Submit
          for(var i=0; i<arrResult.length; i++){
              line_cd_arr.push(document.getElementById("I_LINE_CD").value); // when QR scan
              insp_doc_no_arr.push(InspDocNo); // when data load
              insp_cd_arr.push(arrInspCd[i]); // when data load
              insp_result_arr.push(arrResult[i]); // user input
              user_cd_arr.push(getCookie("user_cd")); // when login
              rcv_dept_arr.push(""); // default
              remark_arr.push(arrRemark[i]); // user input
              insp_type_arr.push($("#cb_insp_type").val()); // when data load
              insp_criteria_arr.push(arrCriteria[i]); // when data load
              value_std_arr.push(arrValueSTD[i]); // choose 1. when data load, 2. user input
              img_path_arr.push(arrImgPath[i]); // user input
              if($("#cb_insp_type").val() == "FML_LIST" || $("#cb_insp_type").val() == "QC_FML_CHECK" || $("#cb_insp_type").val() == "QC_DIMS_CHECK" || $("#cb_insp_type").val() == "MT_CO2_CHECK") {
                  part_no_arr.push($("#cb_part_no").val());
              }
          }


          if(confirm("Are you sure to submit " + $("#cb_insp_type").val() + "? \n Inspection Result : " + result_code + "\n NG Criteria : " + ng_criteria) == true){
              if ($("#cb_insp_type").val() == "FML_LIST" || $("#cb_insp_type").val() == "QC_FML_CHECK" || $("#cb_insp_type").val() == "QC_DIMS_CHECK" || $("#cb_insp_type").val() == "MT_CO2_CHECK") {
                  var paramObj = {};
                  paramObj["SQL"] = "PKG_INSP_COMMON_NEW.LINE_CHECKLIST_SAVE_PART";
                  paramObj["I_1_LINE_CD"] = line_cd_arr;
                  paramObj["I_2_INSP_DOC_NO"] = insp_doc_no_arr;
                  paramObj["I_3_INSP_CD"] = insp_cd_arr;
                  paramObj["I_4_INSP_RESULT"] = insp_result_arr;
                  paramObj["I_5_USER_CD"] = user_cd_arr;
                  paramObj["I_6_RCV_DEPT_CD"] = rcv_dept_arr;
                  paramObj["I_7_REMARK"] = remark_arr;
                  paramObj["I_8_TYPE"] = insp_type_arr;
                  paramObj["I_9_CRITERIA"] = insp_criteria_arr;
                  paramObj["I_10_STD_VALUE"] = value_std_arr;
                  paramObj["I_11_PART_NO"] = part_no_arr;
                  paramObj["I_12_IMG_PATH"] = img_path_arr;
                  onSave(paramObj, "onSuccessUpdateResult");
              }
              else {
                  var paramObj = {};
                  paramObj["SQL"] = "PKG_INSP_COMMON_NEW.LINE_CHECKLIST_SAVE";
                  paramObj["I_1_LINE_CD"] = line_cd_arr;
                  paramObj["I_2_INSP_DOC_NO"] = insp_doc_no_arr;
                  paramObj["I_3_INSP_CD"] = insp_cd_arr;
                  paramObj["I_4_INSP_RESULT"] = insp_result_arr;
                  paramObj["I_5_USER_CD"] = user_cd_arr;
                  paramObj["I_6_RCV_DEPT_CD"] = rcv_dept_arr;
                  paramObj["I_7_REMARK"] = remark_arr;
                  paramObj["I_8_TYPE"] = insp_type_arr;
                  paramObj["I_9_CRITERIA"] = insp_criteria_arr;
                  paramObj["I_10_STD_VALUE"] = value_std_arr;
                  paramObj["I_11_IMG_PATH"] = img_path_arr;
                  onSave(paramObj, "onSuccessUpdateResult");
              }

              line_cd_arr.length= 0;
              insp_doc_no_arr.length= 0;
              insp_cd_arr.length= 0;
              insp_result_arr.length= 0;
              user_cd_arr.length= 0;
              rcv_dept_arr.length= 0;
              remark_arr.length= 0;
              insp_type_arr.length= 0;
              insp_criteria_arr.length= 0;
              value_std_arr.length= 0;
              part_no_arr.length= 0;
              img_path_arr.length= 0;

              document.getElementById("I_LINE_CD").value = "";
              document.getElementById("I_LINE_NM").value = "";
              $("#cb_insp_type").empty();
              $("#cb_part_no").empty();

              //alert(document.querySelector('input[name="chk_okng_value_1"]:checked').value);
          }
        }

        function onSuccessUpdateResult(data) {
            var result = data.result;
            var msg_code = result[0].msg_code;
            if (msg_code == "1" || msg_code == "2") {
                ShowSystemAlert('[INFO]', ' System Data Updated..', '2000');
                window.location.href = "INSP_PROD.jsp";
                //fn_search();
            }

            fn_clear();
        }


        function fn_report() {
            /*
            if(document.getElementById("I_EXP_NO").value.trim() == ""){
              MsgShow("INFO","Error","Please select Expense Number for Report..");
            }else{
              var param = 'EXP_NO/' + document.getElementById("I_EXP_NO").value;
              var url ='/preview?RPT_FILE=/report/EXPENSE_REPORT.jasper&PARAMS=' + param;
              javascript:void(window.open(url, 'OST Report Viewer','width=800, height=600'));
              fn_clear();
            }
            */
            //var url ='/excelexport?SQL=PKG_MAIN.MENU&I_USER_CD=E0001';
            //window.location.href = url;
            console.log('Order no(report) : ' + InspDocNo);
            var param = 'ORD_NO/' + InspDocNo;
            var url = '/preview?RPT_FILE=/report/HMMA_PM.jasper&PARAMS=' + param;
            //var url ='/preview?RPT_FILE=/report/HMMA_PM.jasper';
            javascript: void(window.open(url, 'HMMA Report Viewer', 'width=1000, height=700'));
            //fn_clear();
        }


        function fn_setCombo() {
            var paramObj = {};
            paramObj = {};
            paramObj["SQL"] = "PKG_COMMON.COMMON_COMBO";
            paramObj["I_GRP_CD"] = 'INSP_TYPE';
            paramObj["I_ALL"] = "Y";
            paramObj["I_ALL_TEXT"] = "Select";
            onSelect(paramObj, "onSuccessComboResult", true);
        }

        function onSuccessComboResult(data) {
            var result = data.result;
            $('#cb_insp_type').empty();
            for (var i = 0; i < result.length; i++) {
                $('#cb_insp_type').append('<option value="' + result[i].code + '">' + result[i].name + '</option>');
                $("#cb_insp_type").selectpicker("refresh");
            }
        }

        function fn_part_Combo() {
            var paramObj = {};
            paramObj = {};
            paramObj["SQL"] = "PKG_INSP_COMMON_NEW.PRS_FML_LIST";

            onSelect(paramObj, "onSuccessComboResult2", true);
        }

        function onSuccessComboResult2(data) {
          var result = data.result;

          $('#cb_part_no').off('change');
          $('#cb_part_no').empty();

          for (var i = 1; i < result.length; i++) {
              $('#cb_part_no').append(
                    '<option value="' + result[i].code + '">'
                  + result[i].code + ' / ' + result[i].name
                  + '</option>'
              );
          }

          $("#cb_part_no").selectpicker("refresh");

          $('#cb_part_no').on('change', function() {
              if (!this.value) { return; }
              fn_load_check_list_part(this.value);
          });
      }


        function fn_setLineCombo() {
            var paramObj = {};
            paramObj["SQL"] = "PKG_COMMON.LINE_COMBO";
            paramObj["I_SHOP_CD"] = $("#cb_shop").val();
            paramObj["I_ALL"] = 'Y';
            paramObj["I_ALL_TEXT"] = "Select";
            onSelect(paramObj, "onSuccessComboResult4", true);
        }

        function fn_setLineCodeCombo() {
            var paramObj = {};
            paramObj["SQL"] = "PKG_COMMON.LINE_CODE_WITH_NAME";
            paramObj["I_LINE_TYPE"] = $("#cb_line_type").val();
            paramObj["I_ALL"] = 'Y';
            paramObj["I_ALL_TEXT"] = "Select";
            onSelect(paramObj, "onSuccessComboResult5", true);
        }

        function checkNumber(event) {
            if((event.keyCode > 47 && event.keyCode <= 57 )
               || event.keyCode == 8 //backspace
               //|| event.keyCode == 37 || event.keyCode == 39 //방향키 →, ←
               || event.keyCode == 46 //delete키
               || event.keyCode == 110 //.키
               || event.keyCode == 190 //.키
               || event.keyCode == 39){
            }else{
            event.returnValue=false;
            }
        }



    </script>

</head>

<body onload="fn_page_init()">

    <div id="container" class="effect aside-float aside-bright mainnav-lg">

        <%@ include file="/OST_lib/ost_header.jsp"%>

        <div class="boxed">
            <!--CONTENT CONTAINER-->
            <div id="content-container">
                <%@ include file="/OST_lib/ost_pgm_path.jsp"%>
                <!--Page content-->
                <div id="page-content">

                  <div class="row">
                      <div class="col-sm-12">
                          <!--Search Panel-->
                          <div class="panel">

                              <div class="panel-heading">
                                  <h3 class="panel-title">Scan QR Code</h3>
                              </div>
                              <div class="panel-body">

                                  <div class="row">
                                      <div class="col-sm-12">
                                          <div class="form-group">
                                              <div id="qr-reader" style="width:500px"></div>
                                              <div id="qr-reader-results"></div>
                                          </div>
                                          <button class="btn btn-default" type="button" onclick="fn_clear()"><i class="fa fa-eraser"></i> Clear</button>
                                          <button class="btn btn-default" type="button" onclick="fn_save()"><i class="fa fa-save"></i> Save</button>
                                      </div>
                                  </div>
                              </div>
                          </div>
                      </div>
                  </div>
                    <!-- Data Table Panel -->
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="panel">
                                <div class="panel-heading">
                                    <h3 class="panel-title">Scan Data</h3>
                                </div>
                                <!--Data Table-->
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                                <label class="control-label">Line Code</label>
                                                <input id="I_LINE_CD" type="text" class="form-control" placeholder="Please Scan Line Code">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                                <label class="control-label">Line Name</label>
                                                <input id="I_LINE_NM" type="text" class="form-control" placeholder="Please Scan Line Code">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                                <label class="control-label">Part no</label>
                                                <input id="I_PART_NO" type="text" class="form-control" placeholder="Please Scan Line Code">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                       <div class="col-sm-12">
                                           <div class="form-group">
                                               <label class="control-label">Prod lot no</label>
                                               <input id="I_PROD_LOT_NO" type="text" class="form-control" placeholder="Please Scan Line Code">
                                           </div>
                                       </div>
                                   </div>
                                    <div class="row">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <label class="control-label">Inspection Type</label>
                                              <select id="cb_insp_type" class="selectpicker" data-live-search="true" data-width="100%">
                                              </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_part_no">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <label class="control-label">FML</label>
                                              <select id="cb_part_no" class="selectpicker" data-live-search="true" data-width="100%">
                                              </select>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!--End Data Table-->
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-12">
                        <!--Search Panel-->
                        <div class="panel">

                            <div class="panel-heading">
                                <h3 class="panel-title">Check Image</h3>
                            </div>
                            <div class="panel-body">

                                <div class="col-sm-3">
                                    <button class="btn btn-default" type="button" onclick="fn_PrevImg()" style="float: left;"> < Prev </button>
                                </div>
                                <div id="I_IMG_COUNT" class="col-sm-6" style="text-align: center;">

                                </div>
                                <div class="col-sm-3">
                                    <button class="btn btn-default" type="button" onclick="fn_NextImg()" style="float: right;"> Next > </button>
                                </div>
                                <div class="row">
                                    <img id="I_CHECK_IMG" src="/img/blank2.jpg" alt="..." class="img-thumbnail" style="display: block; margin: auto;">
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- End Data Table Panel -->

                    <!-- Inspection Data Table Panel -->
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="panel">
                                <div class="panel-heading">
                                    <h3 class="panel-title">Inspection List (OK/NG)</h3>
                                </div>
                                <!--Data Table-->
                                <div class="panel-body">
                                    <div class="row" id="div_okng_1" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_1" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_1" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_1" class="magic-radio" type="radio" value="OK" name="chk_okng_value_1">
                                                    <label for="chk_okng_ok_1">OK</label>
                                                    <input id="chk_okng_ng_1" class="magic-radio" type="radio" value="NG" name="chk_okng_value_1">
                                                    <label for="chk_okng_ng_1">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_1" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_1" class="form-control" readonly>
                                                          <input id="chk_okng_img_1" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_1')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_1')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>

                                    </div>
                                    <div class="row" id="div_okng_2" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_2" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_2" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_2" class="magic-radio" type="radio" value="OK" name="chk_okng_value_2">
                                                    <label for="chk_okng_ok_2">OK</label>
                                                    <input id="chk_okng_ng_2" class="magic-radio" type="radio" value="NG" name="chk_okng_value_2">
                                                    <label for="chk_okng_ng_2">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_2" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_2" class="form-control" readonly>
                                                          <input id="chk_okng_img_2" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_2')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_2')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_3" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_3" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_3" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_3" class="magic-radio" type="radio" value="OK" name="chk_okng_value_3">
                                                    <label for="chk_okng_ok_3">OK</label>
                                                    <input id="chk_okng_ng_3" class="magic-radio" type="radio" value="NG" name="chk_okng_value_3">
                                                    <label for="chk_okng_ng_3">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_3" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_3" class="form-control" readonly>
                                                          <input id="chk_okng_img_3" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_3')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_3')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_4" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_4" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_4" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_4" class="magic-radio" type="radio" value="OK" name="chk_okng_value_4">
                                                    <label for="chk_okng_ok_4">OK</label>
                                                    <input id="chk_okng_ng_4" class="magic-radio" type="radio" value="NG" name="chk_okng_value_4">
                                                    <label for="chk_okng_ng_4">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_4" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_4" class="form-control" readonly>
                                                          <input id="chk_okng_img_4" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_4')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_4')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_5" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_5" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_5" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_5" class="magic-radio" type="radio" value="OK" name="chk_okng_value_5">
                                                    <label for="chk_okng_ok_5">OK</label>
                                                    <input id="chk_okng_ng_5" class="magic-radio" type="radio" value="NG" name="chk_okng_value_5">
                                                    <label for="chk_okng_ng_5">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_5" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_5" class="form-control" readonly>
                                                          <input id="chk_okng_img_5" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_5')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_5')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                              </div>
                                            </div>
                                    </div>
                                    <div class="row" id="div_okng_6" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_6" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_6" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_6" class="magic-radio" type="radio" value="OK" name="chk_okng_value_6">
                                                    <label for="chk_okng_ok_6">OK</label>
                                                    <input id="chk_okng_ng_6" class="magic-radio" type="radio" value="NG" name="chk_okng_value_6">
                                                    <label for="chk_okng_ng_6">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_6" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_6" class="form-control" readonly>
                                                          <input id="chk_okng_img_6" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_6')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_6')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                              </div>
                                            </div>
                                    </div>
                                    <div class="row" id="div_okng_7" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_7" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_7" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_7" class="magic-radio" type="radio" value="OK" name="chk_okng_value_7">
                                                    <label for="chk_okng_ok_7">OK</label>
                                                    <input id="chk_okng_ng_7" class="magic-radio" type="radio" value="NG" name="chk_okng_value_7">
                                                    <label for="chk_okng_ng_7">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_7" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_7" class="form-control" readonly>
                                                          <input id="chk_okng_img_7" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_7')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_7')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                              </div>
                                            </div>
                                    </div>
                                    <div class="row" id="div_okng_8" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_8" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_8" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_8" class="magic-radio" type="radio" value="OK" name="chk_okng_value_8">
                                                    <label for="chk_okng_ok_8">OK</label>
                                                    <input id="chk_okng_ng_8" class="magic-radio" type="radio" value="NG" name="chk_okng_value_8">
                                                    <label for="chk_okng_ng_8">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_8" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_8" class="form-control" readonly>
                                                          <input id="chk_okng_img_8" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_8')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_8')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                              </div>
                                            </div>
                                    </div>
                                    <div class="row" id="div_okng_9" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_9" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_9" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_9" class="magic-radio" type="radio" value="OK" name="chk_okng_value_9">
                                                    <label for="chk_okng_ok_9">OK</label>
                                                    <input id="chk_okng_ng_9" class="magic-radio" type="radio" value="NG" name="chk_okng_value_9">
                                                    <label for="chk_okng_ng_9">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_9" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_9" class="form-control" readonly>
                                                          <input id="chk_okng_img_9" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_9')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_9')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                              </div>
                                            </div>
                                    </div>
                                    <div class="row" id="div_okng_10" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_10" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_10" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_10" class="magic-radio" type="radio" value="OK" name="chk_okng_value_10">
                                                    <label for="chk_okng_ok_10">OK</label>
                                                    <input id="chk_okng_ng_10" class="magic-radio" type="radio" value="NG" name="chk_okng_value_10">
                                                    <label for="chk_okng_ng_10">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_10" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_10" class="form-control" readonly>
                                                          <input id="chk_okng_img_10" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_10')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_10')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                              </div>
                                            </div>
                                    </div>
                                    <div class="row" id="div_okng_11" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_11" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_11" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_11" class="magic-radio" type="radio" value="OK" name="chk_okng_value_11">
                                                    <label for="chk_okng_ok_11">OK</label>
                                                    <input id="chk_okng_ng_11" class="magic-radio" type="radio" value="NG" name="chk_okng_value_11">
                                                    <label for="chk_okng_ng_11">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_11" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_11" class="form-control" readonly>
                                                          <input id="chk_okng_img_11" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_11')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_11')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_12" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_12" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_12" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_12" class="magic-radio" type="radio" value="OK" name="chk_okng_value_12">
                                                    <label for="chk_okng_ok_12">OK</label>
                                                    <input id="chk_okng_ng_12" class="magic-radio" type="radio" value="NG" name="chk_okng_value_12">
                                                    <label for="chk_okng_ng_12">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_12" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_12" class="form-control" readonly>
                                                          <input id="chk_okng_img_12" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_12')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_12')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_13" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_13" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_13" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_13" class="magic-radio" type="radio" value="OK" name="chk_okng_value_13">
                                                    <label for="chk_okng_ok_13">OK</label>
                                                    <input id="chk_okng_ng_13" class="magic-radio" type="radio" value="NG" name="chk_okng_value_13">
                                                    <label for="chk_okng_ng_13">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_13" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_13" class="form-control" readonly>
                                                          <input id="chk_okng_img_13" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_13')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_13')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_14" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_14" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_14" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_14" class="magic-radio" type="radio" value="OK" name="chk_okng_value_14">
                                                    <label for="chk_okng_ok_14">OK</label>
                                                    <input id="chk_okng_ng_14" class="magic-radio" type="radio" value="NG" name="chk_okng_value_14">
                                                    <label for="chk_okng_ng_14">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_14" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_14" class="form-control" readonly>
                                                          <input id="chk_okng_img_14" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_14')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_14')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_15" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_15" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_15" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_15" class="magic-radio" type="radio" value="OK" name="chk_okng_value_15">
                                                    <label for="chk_okng_ok_15">OK</label>
                                                    <input id="chk_okng_ng_15" class="magic-radio" type="radio" value="NG" name="chk_okng_value_15">
                                                    <label for="chk_okng_ng_15">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_15" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_15" class="form-control" readonly>
                                                          <input id="chk_okng_img_15" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_15')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_15')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_16" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_16" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_16" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_16" class="magic-radio" type="radio" value="OK" name="chk_okng_value_16">
                                                    <label for="chk_okng_ok_16">OK</label>
                                                    <input id="chk_okng_ng_16" class="magic-radio" type="radio" value="NG" name="chk_okng_value_16">
                                                    <label for="chk_okng_ng_16">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_16" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_16" class="form-control" readonly>
                                                          <input id="chk_okng_img_16" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_16')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_16')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_17" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_17" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_17" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_17" class="magic-radio" type="radio" value="OK" name="chk_okng_value_17">
                                                    <label for="chk_okng_ok_17">OK</label>
                                                    <input id="chk_okng_ng_17" class="magic-radio" type="radio" value="NG" name="chk_okng_value_17">
                                                    <label for="chk_okng_ng_17">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_17" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_17" class="form-control" readonly>
                                                          <input id="chk_okng_img_17" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_17')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_17')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_18" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_18" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_18" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_18" class="magic-radio" type="radio" value="OK" name="chk_okng_value_18">
                                                    <label for="chk_okng_ok_18">OK</label>
                                                    <input id="chk_okng_ng_18" class="magic-radio" type="radio" value="NG" name="chk_okng_value_18">
                                                    <label for="chk_okng_ng_18">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_18" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_18" class="form-control" readonly>
                                                          <input id="chk_okng_img_18" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_18')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_18')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_19" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_19" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_19" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_19" class="magic-radio" type="radio" value="OK" name="chk_okng_value_19">
                                                    <label for="chk_okng_ok_19">OK</label>
                                                    <input id="chk_okng_ng_19" class="magic-radio" type="radio" value="NG" name="chk_okng_value_19">
                                                    <label for="chk_okng_ng_19">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_19" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_19" class="form-control" readonly>
                                                          <input id="chk_okng_img_19" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_19')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_19')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_okng_20" style="display:none;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_okng_criteria_20" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_okng_std_20" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="radio">
                                                    <input id="chk_okng_ok_20" class="magic-radio" type="radio" value="OK" name="chk_okng_value_20">
                                                    <label for="chk_okng_ok_20">OK</label>
                                                    <input id="chk_okng_ng_20" class="magic-radio" type="radio" value="NG" name="chk_okng_value_20">
                                                    <label for="chk_okng_ng_20">NG</label>
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                <input type="text" id="chk_okng_rmk_20" class="form-control" placeholder="Remark input here...">
                                                </div>
                                                <div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_okng_path_20" class="form-control" readonly>
                                                          <input id="chk_okng_img_20" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_20')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_okng_path_20')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!--End Data Table-->
                            </div>
                        </div>
                    </div>
                    <!-- Inspection Data Table Panel -->

                    <!-- Inspection Data Table Panel (Check Value)-->
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="panel">
                                <div class="panel-heading">
                                    <h3 class="panel-title">Inspection List (Check Value)</h3>
                                </div>
                                <!--Data Table-->
                                <div class="panel-body">
                                    <div class="row" id="div_range_1" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_1" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_1" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                    <input type="text" id="chk_range_value_1" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_1" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_1" class="form-control" readonly>
                                                          <input id="chk_range_img_1" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_1')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_1')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row"  id="div_range_2" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_2" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_2" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_2" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_2" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_2" class="form-control" readonly>
                                                          <input id="chk_range_img_2" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_2')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_2')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_3" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_3" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_3" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_3" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_3" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_3" class="form-control" readonly>
                                                          <input id="chk_range_img_3" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_3')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_3')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_4" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_4" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_4" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_4" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_4" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_4" class="form-control" readonly>
                                                          <input id="chk_range_img_4" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_4')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_4')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_5" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_5" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_5" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_5" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_5" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_5" class="form-control" readonly>
                                                          <input id="chk_range_img_5" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_5')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_5')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_6" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_6" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_6" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_6" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_6" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_6" class="form-control" readonly>
                                                          <input id="chk_range_img_6" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_6')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_6')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_7" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_7" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_7" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_7" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_7" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_7" class="form-control" readonly>
                                                          <input id="chk_range_img_7" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_7')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_7')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_8" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_8" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_8" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_8" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_8" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_8" class="form-control" readonly>
                                                          <input id="chk_range_img_8" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_8')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_8')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_9" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_9" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_9" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_9" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_9" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_9" class="form-control" readonly>
                                                          <input id="chk_range_img_9" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_9')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_9')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_10" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_10" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_10" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_10" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_10" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_10" class="form-control" readonly>
                                                          <input id="chk_range_img_10" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_10')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_10')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_11" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_11" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_11" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_11" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_11" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_11" class="form-control" readonly>
                                                          <input id="chk_range_img_11" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_11')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_11')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_12" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_12" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_12" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_12" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_12" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_12" class="form-control" readonly>
                                                          <input id="chk_range_img_12" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_12')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_12')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_13" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_13" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_13" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_13" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_13" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_13" class="form-control" readonly>
                                                          <input id="chk_range_img_13" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_13')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_13')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_14" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_14" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_14" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_14" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_14" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_14" class="form-control" readonly>
                                                          <input id="chk_range_img_14" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_14')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_14')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_15" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_15" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_15" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_15" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_15" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_15" class="form-control" readonly>
                                                          <input id="chk_range_img_15" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_15')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_15')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_16" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_16" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_16" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_16" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_16" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_16" class="form-control" readonly>
                                                          <input id="chk_range_img_16" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_16')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_16')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_17" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_17" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_17" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_17" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_17" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_17" class="form-control" readonly>
                                                          <input id="chk_range_img_17" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_17')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_17')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_18" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_18" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_18" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_18" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_18" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_18" class="form-control" readonly>
                                                          <input id="chk_range_img_18" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_18')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_18')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_19" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_19" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_19" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_19" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_19" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_19" class="form-control" readonly>
                                                          <input id="chk_range_img_19" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_19')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_19')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row" id="div_range_20" style="display:none;margin-top: 10px;">
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                              <!--<label class="col-sm-3 control-label" for="demo-readonly-input">#1</label>-->
                                              <div class="col-sm-4">
                                                <input type="text" id="chk_range_criteria_20" class="form-control" placeholder="Readonly input here..." readonly>
                                              </div>
                                              <div class="col-sm-4">
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_std_20" class="form-control" placeholder="Standard Value" readonly>
                                                </div>
                                                <div class="col-sm-6">
                                                  <input type="text" id="chk_range_value_20" class="form-control" onkeydown="return checkNumber(event);" placeholder="Checked Value input here..." >
                                                </div>
                                              </div>
                                              <div class="col-sm-4">
	                                              <div class="col-sm-6">
                                                  <input type="text" id="chk_range_rmk_20" class="form-control" placeholder="Remark input here...">
                                    						</div>
                                    						<div class="col-sm-6">
                                                  <div class="form-group">
                                                      <div class="input-group mar-btm">
                                                          <input type="text" id="chk_range_path_20" class="form-control" readonly>
                                                          <input id="chk_range_img_20" type="text" style='display: none' class="form-control" placeholder="Click For Picture Upload" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_20')">
                                                          <span class="input-group-btn">
                                                              <button class="btn btn-primary" type="button" onClick="fn_getUploadPath('Okng_Picture_Upload', 'chk_range_path_20')"><i class="fas fa-upload"></i></button>
                                                          </span>
                                                      </div>
                                                  </div>
                                                </div>
                                              </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!--End Data Table-->
                            </div>
                        </div>
                    </div>
                    <!-- Inspection Data Table Panel (Check Value)-->

                    <div class="row">
                        <div class="col-sm-12">
                            <div class="panel">
                                <form>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="col-sm-10">
                                            </div>
                                            <div class="col-sm-2">
                                                <button class="btn btn-default" type="button" onclick="fn_save()"><i class="fa fa-save"></i> Save</button>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>


                </div>
                <!--End page content-->
            </div>
            <!--END CONTENT CONTAINER-->

            <%@ include file="/OST_lib/ost_nav_menu.jsp"%>

        </div>

        <%@ include file="/OST_lib/ost_footer.jsp"%>

    </div>
    <!-- END OF CONTAINER -->




</body>

</html>
