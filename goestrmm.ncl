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

band = "b01"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Domain files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



trmm1 = "/scratch3/marcelo/studies/LP2002/Data/synop/TRMM/2002/3B42.20020219.15.7A.nc"
trmm2 = "/scratch3/marcelo/studies/LP2002/Data/synop/TRMM/2002/3B42.20020219.18.7A.nc"
trmm3 = "/scratch3/marcelo/studies/LP2002/Data/synop/TRMM/2002/3B42.20020219.21.7A.nc"

topo = "/scratch3/marcelo/studies/LP2002/Data/"+boundary+"/"+version+"/wrfout_d04_2002-02-19_00:00:00"
rainfile = "/scratch3/marcelo/studies/LP2002/Data/"+boundary+"/"+version+"/RAIN.nc"
graupfile = "/scratch3/marcelo/studies/LP2002/Data/"+boundary+"/"+version+"/GRAUPEL.nc"

goes1 = "/scratch3/marcelo/studies/LP2002/Data/synop/GOES/GOES8_d20020219_t151514_"+band+".nc"
goes2 = "/scratch3/marcelo/studies/LP2002/Data/synop/GOES/GOES8_d20020219_t174514_"+band+".nc"
goes3 = "/scratch3/marcelo/studies/LP2002/Data/synop/GOES/GOES8_d20020219_t204514_"+band+".nc"


modelfile = "/scratch3/marcelo/studies/LP2002/Data/eraint/control/RAIN.nc"
c = addfile(modelfile,"r")
rain_mod= wrf_user_getvar(c,"RAINNC",-1)
rmod1 = rain_mod(63,:,:)-rain_mod(60,:,:)
rmod2 = rain_mod(66,:,:)-rain_mod(63,:,:)
rmod3 = rain_mod(69,:,:)-rain_mod(66,:,:)

b1 = addfile(trmm1,"r")
b2 = addfile(trmm2,"r")
b3 = addfile(trmm3,"r")

rtrm1 = b1->pcp*3
rtrm2 = b2->pcp*3
rtrm3 = b3->pcp*3


lat1 = b1->latitude  
lon1 = b1->longitude


 a = addfile(topo,"r")
    it =  -1
  hgt = wrf_user_getvar(a,"HGT",it)
  ;landmask = wrf_user_getvar(a,"LANDMASK",it)
  ;hgt = mask(hgt,landmask.ge.1,True) 
  lat = wrf_user_getvar(a,"XLAT",it)
  lon = wrf_user_getvar(a,"XLONG",it)

   nlat        = dimsizes(lat(0,:,0))
   nlon        = dimsizes(lon(0,0,:))


 f1    = addfile(goes1,"r")
 f2    = addfile(goes2,"r")
 f3    = addfile(goes3,"r")

 cgoe1   = f1->data          ; float data(time, yc, xc) ;
 cgoe2   = f2->data          ; float data(time, yc, xc) ;
 cgoe3   = f3->data          ; float data(time, yc, xc) ;
                           
;*********************************
; Fix the variables so it has recognizable missing data
;*********************************
   cgoe1@_FillValue   = 255.   ; guess
   cgoe2@_FillValue   = 255.   ; guess
   cgoe3@_FillValue   = 255.   ; guess


   lat2d  = f1->lat
   lon2d  = f1->lon

   lat1d  = ndtooned(f1->lat)
   lon1d  = ndtooned(f1->lon)

   lat1d@_FillValue = max(lat1d)
   lon1d@_FillValue = max(lon1d)


                           ; region 
   print("lat1d: min="+min(lat1d)+"   max="+max(lat1d))
   print("lon1d: min="+min(lon1d)+"   max="+max(lon1d))

   crTime  = f1->crTime     ; assorted info
   crDate  = f1->crDate
   lineRes = f1->lineRes
   elemRes = f1->elemRes
   print("crTime ="+crTime +"    crDate ="+crDate)
   print("lineRes="+lineRes+"    elemRes="+elemRes)

;*********************************
; create plot
;*********************************

  lat_start = -13.1
  lon_start = -70.3
  lat_end = -19.0
  lon_end = -64.6



  ; sfx     = get_file_suffix(fili,0)           ; use file name         

   pltType = "png"                             ; "ps", "eps", "pdf", "png", "x11"
   pltDir  = "./"

   wks = gsn_open_wks(pltType, "goetrmmod_"+version) 

  res                = True
  res@gsnFrame       = False
  res@gsnDraw        = False
  res@gsnLeftString  = ""
  res@gsnRightString = ""

mpres                       = res
  mpres@mpProjection              = "Mercator" ; choose map projection
;  res@mpCenterLatF              = -16.        ; choose center lat
;  res@mpCenterLonF              =  -61.        ; choose center lon
;  res@mpCenterRotF              =  0.        ; rotate the globe
  mpres@mpLimitMode           = "Corners"  
  mpres@mpOutlineOn                 = True
  mpres@mpOutlineBoundarySets       = "National"
  mpres@mpDataBaseVersion           = "MediumRes"
  mpres@mpDataSetName               = "Earth..4" 

   mpres@mpLeftCornerLatF      = lat(0,0,0)
  mpres@mpLeftCornerLonF      = lon(0,0,0)
  mpres@mpRightCornerLatF     = lat(0,nlat-1,nlon-1)
  mpres@mpRightCornerLonF     = lon(0,nlat-1,nlon-1)
  ; mpres@mpFillOn            = False

  ; mpres@mpLeftCornerLatF      = lat_end
  ; mpres@mpLeftCornerLonF      = lon_start
  ; mpres@mpRightCornerLatF     = lat_start
  ; mpres@mpRightCornerLonF     = lon_end
  mpres@mpLandFillColor             = "transparent"
  mpres@mpOceanFillColor = "paleturquoise"
  mpres@mpInlandWaterFillColor= "paleturquoise"
  mpres@mpOutlineOn               = True        ; turn on continental outlines
  mpres@mpGridAndLimbOn           = False
  ; mpres@mpGridLineColor             = "black"
  ; mpres@mpGridSpacingF              = 1.0
  ; mpres@mpGridLineThicknessF = 2.0
  ; mpres@mpGridLineDashPattern     = 2
   mpres@pmTickMarkDisplayMode  = "Always" 

   cres = res
   cres@cnFillOn            = True            ; turn on color
   cmap = read_colormap_file("MPL_gist_gray") 
   ; cmap = read_colormap_file("MPL_Greys") 
    ;cmap (123:127,:) = 0.0  ; colormap starts with white
  
  cres@cnFillOpacityF = 0.7    ; uncomment to maximize size
;
  cres@cnFillPalette        = cmap
   ;res@cnFillPalette       = "gsdtol"          ; set color map
   ;cres@cnFillMode          = "RasterFill"    ; cell mode
   cres@cnLinesOn           = False           ; Turn off contour lines
   cres@cnLevelSelectionMode = "ManualLevels"
   cres@cnMinLevelValF = 2000
   cres@cnMaxLevelValF = 14000
   cres@cnLevelSpacingF = 200
  cres@lbLabelBarOn   = False
  cres@lbOrientation       = "Vertical" 
   cres@gsnAddCyclic        = False           ; data not cyclic
   cres@pmTickMarkDisplayMode = "Always" 
    cres@lbTitleFontHeightF = 0.01  
  cres@lbLabelFontHeightF = 0.01 
cres@lbTitleOn        =  True                ; turn on title
  
;cres@pmLabelBarParallelPosF = -0.05 
  cres@lbTitleString    = "counts"                ; title string
  ;cres@lbTitlePosition  = "Right" 
  cres@lbTitleDirection = "Across"             ; title direction
        ; use NCL default 
  ;res@lbOrientation       = "Vertical"      ; vertical label bar

    ; cres@mpMinLatF           = min(lat1d)    ; region to zoom in on
    ; cres@mpMaxLatF           = max(lat1d)
    ; cres@mpMinLonF           = min(lon1d)
    ; cres@mpMaxLonF           = max(lon1d)
cres@cnInfoLabelOn  = False
cres@cnLinesOn             = False            ; turn off contour lines
cres@cnLineLabelsOn        = False          ; turn off contour labels

   cres@sfXArray            = lon2d
   cres@sfYArray            = lat2d
  ;res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries
  ;res@mpOutlineBoundarySets = "AllBoundaries"
   
   cres@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.
   ;res@gsnLeftString       = d@type
   ;cres@tiMainString        = timem+band
   cres@pmLabelBarOrthogonalPosF = 0.05
   

   cres2                     = res 
 cres2@cnLevelSelectionMode  = "ExplicitLevels"
  cres2@cnLevels              = ispan(0,5600,100)
  cres2@cnFillOn              = True             ; color plot desired
  ;cres2@cnFillMode            = "RasterFill"
  cres2@cnLinesOn             = False            ; turn off contour lines
  cres2@cnLineLabelsOn        = False          ; turn off contour labels
   cres2@lbLabelBarOn = False
   cres2@cnInfoLabelOn        = False
   cres2@cnLineThicknessF = 0.4
  cres2@cnFillPalette   = "OceanLakeLandSnow"
  cres2@lbTitleString    = "Elevation (m)"
  cres2@lbOrientation = "Vertical"
  cres2@lbTitleFontHeightF = 0.015   
  cres2@lbLabelFontHeightF = 0.015          ; make title smaller
  ;cres2@pmLabelBarOrthogonalPosF = -0.05   
   cres2@sfXArray = lon(0,:,:)
  cres2@sfYArray = lat(0,:,:)        ; move whole thing down
 cres2@cnFillDrawOrder = "Predraw"
 ;cres2@cnLineDrawOrder = "Predraw"


arr = (/ .1, .3, 0.6, 1, 2, 3, 4, \
                                    5, 7, 10 , 20/)
colors = (/ "transparent","orange","yellow4", \
                                "yellow3","yellow2", \
                                    "yellow","goldenrod","orange", \
                                    "coral","red","violetred","Violet"/)
arr1 = (/ .1, 1.5, 4, 7 ,15/)
colors1=read_colormap_file("prcp_2")
colors1(0,:) = 0.0
;labels = new(dimsizes(arr)+1,string)  ; Labels for legend.
opts_r = res       
 
 ;  opts_r@cnLevelSelectionMode = "ManualLevels"                 
 ; opts_r@cnMinLevelValF  = 0.1     ; set the minimum contour level
 ;  opts_r@cnMaxLevelValF  = 20.1     ; set the maximum contour level
 ;  opts_r@cnLevelSpacingF = 1.
   ;opts_r@UnitLabel            = "mm"
    opts_r@lbTitleFontHeightF = 0.01   
  opts_r@lbLabelFontHeightF = 0.01 
    opts_r@cnFillOpacityF  = 0.9
    opts_r@cnLevelSelectionMode = "ExplicitLevels"
    opts_r@cnLevels             = arr1
    opts_r@cnLineColor         = "blue"
    opts_r@cnFillColor        = "blue"
    opts_r@cnInfoLabelOn        = False
    opts_r@cnLineLabelsOn      = False
    opts_r@cnFillOn             = True
     opts_r@cnMonoFillColor = True                 ; default color is fground [black]
 opts_r@cnMonoFillPattern = False              ; want multiple patterns 
 opts_r@cnMonoFillScale   = False              ; want patterns w/ diff densities 
    opts_r@lbLabelPosition = "Center"                 ; turn off info label box
opts_r@cnFillPatterns    = (/ -1 ,17 ,2, 1,6 ,16/) ; stipling
 opts_r@cnFillScales      = (/1., 0.5, 0.5,0.5,0.5,0.5/) ; stiple density

opts_r@pmLabelBarOrthogonalPosF = -0.055 
       opts_r@sfXArray = lon1
      opts_r@sfYArray = lat1
      opts_r@lbLabelBarOn   = False
      opts_r@lbOrientation = "Vertical"
      opts_r@lbTitleOn        =  True                ; turn on title
  opts_r@lbTitleString    = "mm"                ; title string
  ;opts_r@lbTitlePosition  = "Right" 
    opts_r@cnFillDrawOrder = "Postdraw"
 opts_r@lbTitleDirection = "Across"             ; title direction


opts_r1 = res                        
  ;  opts_r@UnitLabel            = "mm"
    opts_r1@cnFillOpacityF  = 0.35
    opts_r1@cnLevelSelectionMode = "ExplicitLevels"
    opts_r1@cnLevels             = (/ .1, .2, .4, .8, 1.6, 3.2, 6.4, \
                                    12.8, 25.6, 51.2, 102.4/)
    opts_r1@cnFillColors         = (/ "transparent","cornsilk","DarkOliveGreen1", \
                                "DarkOliveGreen3","Chartreuse", \
                                    "Chartreuse3","Green","ForestGreen", \
                                    "Yellow","Orange","Red","Violet"/)
   
   ; opts_r1@cnLevels             = (/ 15, 18, 21, 24, 27, 30, 33, 36, \
   ;                                 39, 42, 45/)
   ;   opts_r1@cnFillColors         = (/ "transparent","ForestGreen", \
   ;                           "Green","Chartreuse3","Chartreuse", "DarkOliveGreen1",\
   ;                                 "Yellow","Orange","Red","firebrick3","pink","Violet"/)
    opts_r1@cnInfoLabelOn        = False
    opts_r1@cnConstFLabelOn      = False
    opts_r1@cnFillOn             = True
    opts_r1@cnLinesOn             = False
    opts_r1@lbLabelBarOn        = False
;    opts_r@mpOutlineOn   = False
    opts_r1@sfXArray = lon(0,:,:)
     opts_r1@sfYArray = lat(0,:,:)




  ; nt   = 0
   plot = new(3,graphic) 

  ; dat1d  = ndtooned(d(nt,:,:))

   map1 = gsn_csm_map(wks,mpres)
   mod1 = gsn_csm_contour(wks,rmod1,opts_r1)
   trm1 = gsn_csm_contour(wks,rtrm1(0,:,:),opts_r)
   goe1 = gsn_csm_contour(wks,cgoe1(0,:,:), cres)
   ;plot = gsn_csm_contour(wks,dat1d, cres)
   overlay(map1,trm1)
   overlay(map1,goe1) 
   overlay(map1,mod1)
  
 plot(0)=map1


   map2 = gsn_csm_map(wks,mpres)
   mod2 = gsn_csm_contour(wks,rmod2,opts_r1)
   trm2 = gsn_csm_contour(wks,rtrm2(0,:,:),opts_r)
   goe2 = gsn_csm_contour(wks,cgoe2(0,:,:), cres)
   ;plot = gsn_csm_contour(wks,dat1d, cres)
   overlay(map2,trm2)
   overlay(map2,goe2) 
   overlay(map2,mod2)
  
 plot(1)=map2




   map3 = gsn_csm_map(wks,mpres)
   mod3 = gsn_csm_contour(wks,rmod3,opts_r1)
   trm3 = gsn_csm_contour(wks,rtrm3(0,:,:),opts_r)
   goe3 = gsn_csm_contour(wks,cgoe3(0,:,:), cres)
   ;plot = gsn_csm_contour(wks,dat1d, cres)
   overlay(map3,trm3)
   overlay(map3,goe3) 
   overlay(map3,mod3)
  
 plot(2)=map3

 resP                = True                ; panel only resources
;  resP@gsnPaperOrientation = "auto" 
resP@gsnFrame            = False             ; don't advance the frame, so we can use gsn_text_ndc
  resP@gsnMaximize    = True                ; maximize plots
  ; resP@gsnPaperOrientation = "landscape"
resP@gsnPanelFigureStrings  = (/"a","b","c"/) + ")"
 ;resP@gsnPanelDebug = True
  resP@gsnPanelLabelBar    = True
  resP@lbOrientation       = "vertical" ; vertical label bar

 gsn_panel(wks,plot,(/1,3/),resP)  

frame(wks)


   end
