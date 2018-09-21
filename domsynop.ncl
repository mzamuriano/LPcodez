;************************************************
;
;	Plot 1: Includes domain, topographic data, synoptic conditions 
;			and satellite/model rain estimations
;			Marcelo Zamuriano, Sep 2018
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl" 


;************************************************
begin
;************************************************
; read in file
;************************************************

boundary = "eraint" 
version = "control"
day = 19
time = 18

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Domain files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATADir = "/scratch3/marcelo/studies/LP2002/Data/"+boundary+"/"+version+"/"
FILES = systemfunc (" ls -1 " + DATADir + "*17_00:00:00")
numFILES = dimsizes(FILES)

a = addfiles(FILES,"r")
it  = 0
  hgt1 = wrf_user_getvar(a[0],"HGT",it)
  a1lat = wrf_user_getvar(a[0],"XLAT",it)
  a1lon = wrf_user_getvar(a[0],"XLONG",it)
 
  hgt2 = wrf_user_getvar(a[1],"HGT",it)
  a2lat = wrf_user_getvar(a[1],"XLAT",it)
  a2lon = wrf_user_getvar(a[1],"XLONG",it)

  hgt3 = wrf_user_getvar(a[2],"HGT",it)
  a3lat = wrf_user_getvar(a[2],"XLAT",it)
  a3lon = wrf_user_getvar(a[2],"XLONG",it)

  hgt4 = wrf_user_getvar(a[3],"HGT",it)
  a4lat = wrf_user_getvar(a[3],"XLAT",it)
  a4lon = wrf_user_getvar(a[3],"XLONG",it)

   hgt1@lat2d = a1lat
   hgt1@lon2d = a1lon
   hgt2@lat2d = a2lat
   hgt2@lon2d = a2lon
   hgt3@lat2d = a3lat
   hgt3@lon2d = a3lon
   hgt4@lat2d = a4lat
   hgt4@lon2d = a4lon

  nlat1        = dimsizes(a1lat(:,0))
  nlon1        = dimsizes(a1lon(0,:))
  nlat2        = dimsizes(a2lat(:,0))
  nlon2        = dimsizes(a2lon(0,:))
  nlat3        = dimsizes(a3lat(:,0))
  nlon3        = dimsizes(a3lon(0,:))
  nlat4        = dimsizes(a4lat(:,0))
  nlon4        = dimsizes(a4lon(0,:))

delete(a)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Synoptic files 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

timem = "1918"
scfile = "/scratch3/marcelo/studies/LP2002/Data/synop/Reanalysis/"+boundary+"/2002/02/ei.oper.an.pl.regn128sc.200202"+timem+".grib1"
sfcfile = "/scratch3/marcelo/studies/LP2002/Data/synop/Reanalysis/"+boundary+"/2002/02/ei.oper.an.sfc.regn128sc.200202"+timem+".grib1"
uvfile = "/scratch3/marcelo/studies/LP2002/Data/synop/Reanalysis/"+boundary+"/2002/02/ei.oper.an.pl.regn128uv.200202"+timem+".grib1"

a = addfile(sfcfile,"r")
b = addfile(scfile,"r")
c = addfile(uvfile,"r")

hgt = a->Z_GDS4_SFC/9.81
tcw = a->TCW_GDS4_SFC ;Total column water
q = b->Q_GDS4_ISBL*1000
rh = b->R_GDS4_ISBL    
gh = b->Z_GDS4_ISBL/9.81
v = c->V_GDS4_ISBL
u = c->U_GDS4_ISBL

pres = b->lv_ISBL0
lat = b->g4_lat_1
lon = b->g4_lon_2

; We generate plots, but what kind do we prefer?
; type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
 type = "png"

  type@wkWidth = 2500 
  type@wkHeight = 2500 
  

 wks = gsn_open_wks(type,"dom_synop_"+boundary+timem)


  ;---Set common resources for all plots
  res                = True
  res@gsnDraw        = False
  res@gsnFrame       = False
  res@gsnLeftString  = ""
  res@gsnRightString = ""

;---Map plot
  map_res               = res
  ;map_res@gsnMaximize           = True
  ;map_res@gsnLeftStringFontHeightF = 0.02
  map_res@mpOutlineOn               = True        ; turn on continental outlines
  ;map_res@mpGridAndLimbOn           = True
 ; map_res@mpGridLineDashPattern     = 2
  map_res@mpOutlineOn           = True 
  map_res@mpDataBaseVersion     = "MediumRes"         ; better resolution 
  map_res@mpOutlineBoundarySets = "National"     ; more outlines
  map_res@mpDataSetName         = "Earth..4" 
  map_res@mpFillOn              = True
  map_res@mpInlandWaterFillColor ="lightblue"
  map_res@mpOceanFillColor     = "lightblue"
  map_res@mpUSStateLineThicknessF     = 7.0
  map_res@mpNationalLineThicknessF    = 7.0
  map_res@mpLimbLineThicknessF        = 7.0
  map_res@mpGeophysicalLineThicknessF = 7.0
  map_res@mpUSStateLineColor          = "black"
  map_res@mpPerimLineColor            = "black"
  map_res@mpNationalLineColor         = "black"
  map_res@mpLimbLineColor             = "black"
  ;map_res@mpGridLineColor             = 2
  ;map_res@mpGridSpacingF              = 10.0
  map_res@mpGridAndLimbOn           = True
  map_res@mpGridLineColor             = "black"
  map_res@mpGridSpacingF              = 5.0
  map_res@mpGridLineThicknessF = 2.0
  map_res@mpGridLineDashPattern     = 2
  map_res@pmTickMarkDisplayMode  = "Always" 
  ;map_res@mpGridLineThicknessF = 5.0
  map_res@mpGeophysicalLineColor      = "Black"  ; Overwrite basic map settings
  map_res@mpLandFillColor            =-1
  ; map_res@tmXBLabelFontHeightF = 0.015 
  ; map_res@tmYLLabelFontHeightF = 0.015
  ; map_res@tmBorderThicknessF = 10.0
  ; map_res@tmXBMajorThicknessF= 10.0
  ; map_res@tmXBMinorThicknessF= 10.0
  ; map_res@tmYLMajorThicknessF= 10.0
  ; map_res@tmYLMinorThicknessF= 10.0
;---Set map resources based on projection on WRF output file
  ;map_res = wrf_map_resources(a[0],map_res)
 map_res@mpProjection              = "Mercator" ; choose map projection
  map_res@mpLimitMode           = "Corners"  
  map_res@mpLeftCornerLatF      = a1lat(0,0)
  map_res@mpLeftCornerLonF      = a1lon(0,0)
  map_res@mpRightCornerLatF     = a1lat(nlat1-1,nlon1-1)
  map_res@mpRightCornerLonF     = a1lon(nlat1-1,nlon1-1)

;---Set resources for a partially transparent polygon.
  gnres                = True
;  gnres@gsFillOpacityF = 0.8          ; mostly opaque
  gnres@gsLineColor            = "red" 
  gnres@gsLineThicknessF = 2.0 
  gnres@gsLineLabelString= "d01"
  lon_box = (/-79.5,-79.5,-42.6,-42.6,-79.5/)
  lat_box = (/2.2,-32.75,-32.75,2.2,2.2/)

;---Set resources for a partially transparent polygon.
  gnres2                = True
;  gnres2@gsFillOpacityF = 0.8          ; mostly opaque
  gnres2@gsLineColor            = "black" 
  gnres2@gsLineThicknessF = 13.0 
 ; gnres2@gsLineLabelString= "d02"
  lon_box2 = (/-71.06,-71.06,-57.08,-57.08,-71.06/)
  lat_box2 = (/-9.22,-23.56,-23.56,-9.22,-9.22/)

;---Set resources for a partially transparent polygon.
  gnres3                = True
;  gnres3@gsFillOpacityF = 0.8          ; mostly opaque
  gnres3@gsLineColor            = "black" 
;  gnres3@gsLineLabelString= "d03"
  gnres3@gsLineThicknessF = 13.0 
 

;---Set resources for a partially transparent polygon.
  gnres4                = True
;  gnres4@gsFillOpacityF = 0.8          ; mostly opaque
  gnres4@gsLineColor            = "Black" 
 ; gnres4@gsLineLabelString= "d04"
  gnres4@gsLineThicknessF = 13.0 
 

;---Set resources for a partially transparent polygon.
  gnres5                = True
;  gnres4@gsFillOpacityF = 0.8          ; mostly opaque
  gnres5@gsLineColor            = "red" 
  gnres5@gsLineThicknessF = 12.0 
  lon_box5 = (/-69.25,-69.25,-67.5,-67.5,-69.25/)
  lat_box5 = (/-15.50,-17.25,-17.25,-15.5,-15.5/)

;---Set resources for a contour

  cres                       = res            ; plot mods desired
  ;cres@gsnMaximize           = True  
  cres@cnLevelSelectionMode  = "ExplicitLevels"
  cres@cnLevels              = ispan(0,5600,100)
  cres@cnFillOn              = True             ; color plot desired
  cres@cnFillMode            = "RasterFill"
  cres@cnLinesOn             = False            ; turn off contour lines
  cres@cnLineLabelsOn        = False          ; turn off contour labels
  cres@cnFillPalette   = "OceanLakeLandSnow"
  cres@lbTitleString    = "Elevation (m)"
   cres@lbOrientation = "Vertical"
  cres@pmLabelBarOrthogonalPosF = -0.005
   cres@lbLabelPosition = "right" 
  
  ;cres@lbLabelBarOn   = False    ; no individual label bar
  ;cres@cnInfoLabelOn  = False    ; no contour labels
  
  cres@lbTitleFontHeightF = 0.015   
  cres@lbLabelFontHeightF = 0.015          ; make title smaller
  ;cres@pmLabelBarOrthogonalPosF = -.005           ; move whole thing down
 cres@cnFillDrawOrder = "Predraw"
  cres@cnLineDrawOrder = "Predraw"
;cres@mpOceanFillColor     = "lightblue"

 mkres               = True
  mkres@gsMarkerIndex = 17     ; Filled circle
  mkres@gsMarkerSizeF = 0.01

  txres               = True
  txres@txFontHeightF = 0.018
  txres@txFont        = "helvetica-bold"

  txres1              = True
  txres1@txFontHeightF = 0.016
  txres1@txFont        = "helvetica-bold"

  txres2              = True
  txres2@txFontHeightF = 0.010
  txres2@txFont        = "helvetica-bold"

  txres3              = True
  txres3@txFontHeightF = 0.007
  txres3@txFont        = "helvetica-bold"


 plot = new(2,graphic) 

  map = gsn_csm_map(wks,map_res)

 con1 = gsn_csm_contour(wks,hgt1,cres)
 con2 = gsn_csm_contour(wks,hgt2,cres)
 con3 = gsn_csm_contour(wks,hgt3,cres)
 con4 = gsn_csm_contour(wks,hgt4,cres)

 upper2 = gsn_add_polyline(wks,map,a2lon(nlat2-1,:),a2lat(nlat2-1,:),gnres2)
 left2 = gsn_add_polyline(wks,map,a2lon(:,0),a2lat(:,0),gnres2)
 right2 = gsn_add_polyline(wks,map,a2lon(:,nlon2-1),a2lat(:,nlon2-1),gnres2)
 lower2 = gsn_add_polyline(wks,map,a2lon(0,:),a2lat(0,:),gnres2)

 upper3 = gsn_add_polyline(wks,map,a3lon(nlat3-1,:),a3lat(nlat3-1,:),gnres3)
 left3 = gsn_add_polyline(wks,map,a3lon(:,0),a3lat(:,0),gnres3)
 right3 = gsn_add_polyline(wks,map,a3lon(:,nlon3-1),a3lat(:,nlon3-1),gnres3)
 lower3 = gsn_add_polyline(wks,map,a3lon(0,:),a3lat(0,:),gnres3)

 upper4 = gsn_add_polyline(wks,map,a4lon(nlat4-1,:),a4lat(nlat4-1,:),gnres4)
 left4 = gsn_add_polyline(wks,map,a4lon(:,0),a4lat(:,0),gnres4)
 right4 = gsn_add_polyline(wks,map,a4lon(:,nlon4-1),a4lat(:,nlon4-1),gnres4)
 lower4 = gsn_add_polyline(wks,map,a4lon(0,:),a4lat(0,:),gnres4)

 ;poly= gsn_add_polyline(wks,map,lon_box5,lat_box5,gnres5)
 ;dum4=gsn_add_polymarker(wks,map,-67,-14,mkres)
 dum5=gsn_add_polymarker(wks,map,-68.167,-16.484,mkres)

txt1=gsn_add_text(wks,map,"D1",a1lon(nlat1-4,3),a1lat(nlat1-4,nlon1-4),txres)
txt2=gsn_add_text(wks,map,"D2",a2lon(nlat2-11,10),a2lat(nlat2-10,nlon2-9),txres)
txt3=gsn_add_text(wks,map,"D3",a3lon(nlat3-21,25),a3lat(nlat3-21,nlon3-21),txres1)
txt4=gsn_add_text(wks,map,"D4",a4lon(nlat4-61,nlon4-61),a4lat(nlat4-39,nlon4-39),txres2)
txt5=gsn_add_text(wks,map,"La Paz",-66.5,-15.75,txres3)

overlay(map,con1)
 overlay(map,con2)
 overlay(map,con3)
 overlay(map,con4)
 ;maximize_output(wks,res)
 
 delete(cres)
delete(con1)
delete(con2)
delete(con3)
delete(con4)

  plot(0)=map




;---Set resources for a contour
cmap = read_colormap_file("WhiteBlue")
cmap (0:15,:) = 0.0


    qres                       = res            ; plot mods desired
   qres@cnFillOn              = True             ; color plot desired
  qres@cnLinesOn             = False            ; turn off contour lines
  qres@cnLineLabelsOn        = False          ; turn off contour labels
   qres@cnFillPalette   = cmap
   qres@lbTitleString    = "q500 (g/kg)"
   qres@cnLevelSelectionMode = "ManualLevels"
   qres@cnMinLevelValF = 2
   qres@cnMaxLevelValF = 6
   qres@cnLevelSpacingF = 0.5
   qres@lbOrientation = "Vertical"
   qres@pmLabelBarSide = "right" 
   qres@pmLabelBarOrthogonalPosF = -.005
  qres@sfXArray = lon
  qres@sfYArray = lat  
    qres@lbTitleFontHeightF = 0.015   
  qres@lbLabelFontHeightF = 0.015 

;---Set resources for Wind vector plot
  vres                  = res
  vres@vcRefMagnitudeF         = 2.5              ; make vectors larger
  vres@vcMinDistanceF   = 0.02
  vres@vcRefLengthF     = 0.02  
  vres@vcMinFracLengthF = 0.2
  vres@vcGlyphStyle     = "CurlyVector"
  vres@vcRefAnnoOn      = True
  vres@vcLineArrowThicknessF = 4.0
  vres@vcRefAnnoOrthogonalPosF   = -0.18          ; move ref vector
  vres@vcRefAnnoParallelPosF     = 0.20             ; move ref vector over
 
  cres3                       = res            ; plot mods desired
   cres3@cnLineLabelPlacementMode = "computed"
   cres3@cnLevelSelectionMode = "ManualLevels"
   cres3@cnLineLabelDensityF = 0.5
   cres3@cnMinLevelValF = 12000
   cres3@cnMaxLevelValF = 12500
   cres3@cnLevelSpacingF = 10
   cres3@cnLineLabelBackgroundColor = "red"
   cres3@cnFillDrawOrder = "Postdraw"
    cres3@cnLineLabelFontHeightF   = 0.01
   cres3@cnLineLabelInterval        = 1
   cres3@cnLineColor             = "red"
   ;cres3@cnLineLabelFontColor  ="white"
   cres3@cnLineThicknessF = 6.0
  cres3@sfXArray = lon
  cres3@sfYArray = lat        ; move whole thing down
  cres3@cnInfoLabelOn  = False

  cres4                       = res            ; plot mods desired
  cres4@cnLineLabelPlacementMode = "computed"
     cres4@cnLevelSelectionMode = "ManualLevels"
     cres4@cnLineLabelDensityF = 0.75
     cres4@cnMinLevelValF = 5850
     cres4@cnMaxLevelValF = 5900
     cres4@cnLineLabelBackgroundColor = "green2"
     cres4@cnLevelSpacingF = 6
     cres4@cnLineLabelFontHeightF   = 0.01 
     cres4@cnLineLabelInterval        = 1
   ;cres4@cnFillDrawOrder = "Postdraw"
   cres4@cnLineColor             = "green2"
   cres4@cnLineThicknessF = 7.0
  cres4@sfXArray = lon
  cres4@sfYArray = lat        ; move whole thing down
cres4@cnInfoLabelOn   = False 


;---Create plot

 ; lgh = 7
 ; lwind = 13
 lgh = 14
 lwind = 21
 print(pres(lgh))
  print(pres(lwind))


 vec1 = gsn_csm_vector(wks,u(lwind,:,:),v(lwind,:,:),vres)
  conq = gsn_csm_contour(wks,q(lwind,:,:),qres)
 ;con1 = gsn_csm_contour(wks,rh(lwind,:,:),cres)
  congh200 = gsn_csm_contour(wks,gh(lgh,:,:),cres3)
  congh500 = gsn_csm_contour(wks,gh(lwind,:,:),cres4)
 map1 = gsn_csm_map(wks,map_res)
 ;overlay(map,con2)
 overlay(map1,conq)
  overlay(map1,congh500)
 overlay(map1,congh200)

 overlay(map1,vec1)


  plot(1)=map1


  resP                = True                ; panel only resources
;  resP@gsnPaperOrientation = "auto" 
resP@gsnFrame            = False             ; don't advance the frame, so we can use gsn_text_ndc
  resP@gsnMaximize    = True                ; maximize plots
  ; resP@gsnPaperOrientation = "landscape"
  resP@gsnPanelXWhiteSpacePercent = 2
 resP@gsnPanelYWhiteSpacePercent = 2
resP@gsnPanelFigureStrings  = (/"a","b"/) + ")"
 ;resP@gsnPanelDebug = True
  ;resP@gsnPanelLabelBar    = True
 gsn_panel(wks,plot,(/1,2/),resP)  
frame(wks)


end

