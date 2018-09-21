;   Example script to produce cape/cin/lcl/lfc plots

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

boundary = "eraint" 
version = "st1700new"
timem = "19_18"


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
 

DATADir = "/scratch3/marcelo/studies/LP2002/Data/"+boundary+"/"+version+"/wrfout_d04_2002-02-"+timem+":00:00"
rainfile = "/scratch3/marcelo/studies/LP2002/Data/synop/TRMM/2002/3B42.20020219.18.7A.nc"

a = addfile(DATADir,"r")
b = addfile(rainfile,"r")

rain1 = b->pcp*3
lat1 = b->latitude  
lon1 = b->longitude



; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  type = "png"
  
  wks = gsn_open_wks(type,"rainTRMMobs"+timem)
 ; wks = gsn_open_wks(type,"graupel"+boundary+version+timem)
 
  ;gsn_define_colormap(wks,"WhViBlGrYeOrReWh")

; Set some basic resources
  res = True
  res@gsnFrame       = False
  res@gsnDraw        = False
  res@gsnLeftString  = ""
  res@gsnRightString = ""
  ;res@MainTitle                   = "REAL-TIME WRF"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Which times and how many time steps are in the data set?
  times = wrf_user_getvar(a,"XTIME",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file
  
  print(ntimes)
  it =  0                ; only interested in last time
  ;res@TimeLabel = times(it)        ; set Valid time to use on plot
  
  hgt = wrf_user_getvar(a,"HGT",it)

  lat = wrf_user_getvar(a,"XLAT",it)
  lon = wrf_user_getvar(a,"XLONG",it)
 nlat        = dimsizes(lat(:,0))
   nlon        = dimsizes(lon(0,:))
  
; lat_start = -15.25
;   lon_start = -69.5
;   lat_end = -17.5
;   lon_end = -67.25 
  lat_start = -15.5
  lon_start = -69.25
  lat_end = -17.25
  lon_end = -67.5

; options for plotting
pltres = True
  mpres = res
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"
  mpres@mpGridLineColor        = "Black"
  mpres@mpLimbLineColor        = "Black"
  mpres@mpPerimLineColor       = "Black"
  

  mpres@mpLimitMode           = "Corners"  

mpres@mpOutlineOn                 = True
  mpres@mpOutlineBoundarySets       = "AllBoundaries"
  mpres@mpDataBaseVersion           = "MediumRes"
  mpres@mpDataSetName               = "Earth..4" 

 mpres@mpLeftCornerLatF      = lat_end
  mpres@mpLeftCornerLonF      = lon_start
  mpres@mpRightCornerLatF     = lat_start
  mpres@mpRightCornerLonF     = lon_end
  mpres@mpLandFillColor             = "transparent"
  ;mpres@mpOceanFillColor = "paleturquoise"
  mpres@mpInlandWaterFillColor= "paleturquoise"
  mpres@mpOutlineOn               = True        ; turn on continental outlines
  mpres@mpGridAndLimbOn           = True
  mpres@mpGridLineColor             = "black"
  mpres@mpGridSpacingF              = 0.5
  mpres@mpGridLineThicknessF = 2.0 ;                        "Wind (" + u10@units + ")"
  mpres@mpGridLineDashPattern     = 2
  mpres@pmTickMarkDisplayMode  = "Always"




mpres2                   = res

  mpres2@gsnFrame          = False
  mpres2@gsnDraw           = False

; Tickmark stuff
  ;mpres2@pmTickMarkDisplayMode = "Always"
  mpres2@tmXBLabelFontHeightF = 0.01

; Map stuff
  mpres2@mpOutlineBoundarySets       = "AllBoundaries"
  mpres2@mpDataBaseVersion           = "MediumRes"
  mpres2@mpDataSetName               = "Earth..4"
  mpres2@mpOutlineOn       = True
  mpres2@mpLimitMode           = "Corners" 
  mpres2@mpLeftCornerLatF      = lat(0,0)
  mpres2@mpLeftCornerLonF      = lon(0,0)
  mpres2@mpRightCornerLatF     = lat(nlat-1,nlon-1)
  mpres2@mpRightCornerLonF     = lon(nlat-1,nlon-1)
 
  mpres2@mpLandFillColor         = "White"
  mpres2@mpOceanFillColor        = "Gray75"
  mpres2@mpInlandWaterFillColor  = "Gray75"

; Width/height
  mpres2@vpHeightF         = 0.2    ; Make this second map smaller.
  mpres2@vpWidthF          = 0.2

cres1                     = res            ; plot mods desired

 cres1@cnLevelSelectionMode  = "ExplicitLevels"
  cres1@cnLevels              = ispan(0,5600,100)
  cres1@cnFillOn              = True             ; color plot desired
  ;cres2@cnFillMode            = "RasterFill"
  cres1@cnLinesOn             = True            ; turn off contour lines
  cres1@cnLineLabelsOn        = False          ; turn off contour labels
   cres1@cnLineThicknessF = 0.4
  cres1@cnFillPalette   = "OceanLakeLandSnow"
  cres1@lbTitleString    = "Elevation (m)"
  cres1@lbOrientation = "Vertical"
  cres1@lbTitleFontHeightF = 0.015   
  cres1@lbLabelFontHeightF = 0.015          ; make title smaller
  cres1@lbLabelBarOn = False   
   cres1@sfXArray = lon
  cres1@sfYArray = lat       ; move whole thing down
 cres1@cnFillDrawOrder = "Predraw"
 cres1@cnInfoLabelOn  = False
 ;cres2@cnLineDrawOrder = "Predraw"
 

 lnres = True
          lnres@gsLineThicknessF = 4.0
          lnres@gsLineColor = "Red"

map2 = gsn_csm_map(wks,mpres2)
pbox = gsn_add_polyline(wks, map2, (/lon_start,lon_end,lon_end,lon_start,lon_start/), (/lat_end,lat_end,lat_start,lat_start,lat_end/), lnres)
 con2 = gsn_csm_contour(wks,hgt(:,:),cres1)
 overlay(map2,con2)


  ;mpres@gsnRightString = "Time: " 
  ;mpres@mpFillDrawOrder = "Postdraw"



cmap = read_colormap_file("MPL_BuPu")
cmap (0:25,:) = 0.0

arr = (/ .1, .2, .4, .8, 1.5, 3, 6, \
                                    12, 20, 30, 50/)
colors = (/ "white","cornsilk","DarkOliveGreen1", \
                                "DarkOliveGreen3","Chartreuse", \
                                    "Chartreuse3","Green","ForestGreen", \
                                    "Yellow","Orange","Red","Violet"/)
labels = new(dimsizes(arr)+1,string)  ; Labels for legend.
opts_r = res                        
  ;  opts_r@UnitLabel            = "mm"
    opts_r@cnFillOpacityF  = 0.9
    opts_r@cnLevelSelectionMode = "ExplicitLevels"
    opts_r@cnLevels             = arr
    opts_r@cnFillColors         = colors
    opts_r@cnInfoLabelOn        = False
    opts_r@cnConstFLabelOn      = False
    opts_r@cnFillOn             = True
    opts_r@cnLinesOn             = False
    opts_r@lbTitleString    = "mm"
    opts_r@lbOrientation = "Vertical"
    opts_r@sfXArray = lon1
      opts_r@sfYArray = lat1
    opts_r@cnFillDrawOrder = "Predraw"
 
lnres = True
          lnres@gsLineThicknessF = 4.0
          lnres@gsLineColor = "Red"

  opts = res                         
  opts@cnFillOn = True  
  opts@cnLinesOn             = False            ; turn off contour lines
  opts@cnLineLabelsOn        = False          ; turn off contour labels
 
  opts@cnLineLabelsOn = False
  opts@sfXArray = lon
  opts@sfYArray = lat
  ;opts@FieldTitle = "mcape"
  opts@cnLevelSelectionMode  = "ExplicitLevels"
  opts@cnLevels              = ispan(0,50,1)
  opts@cnFillOpacityF = 0.6
  opts@cnFillPalette   = cmap

 cres2                     = res            ; plot mods desired

 cres2@cnLevelSelectionMode  = "ExplicitLevels"
  cres2@cnLevels              = ispan(0,5600,100)
  cres2@cnFillOn              = True             ; color plot desired
  ;cres2@cnFillMode            = "RasterFill"
  cres2@cnLinesOn             = False           ; turn off contour lines
  cres2@cnLineLabelsOn        = False          ; turn off contour labels
  ; cres2@cnLineThicknessF = 0.4
  cres2@cnFillPalette   = "OceanLakeLandSnow"
  ;cres2@lbTitleString    = "Elevation (m)"
  ;cres2@lbOrientation = "Vertical"
  cres2@lbTitleFontHeightF = 0.015   
  cres2@lbLabelFontHeightF = 0.015          ; make title smaller
  ;cres2@pmLabelBarOrthogonalPosF = -.005   
   cres2@sfXArray = lon
  cres2@sfYArray = lat        ; move whole thing down
 cres2@cnFillDrawOrder = "Predraw"
 ;cres2@cnLineDrawOrder = "Predraw"




mkres               = True
  mkres@gsMarkerIndex = 17     ; Filled circle
  mkres@gsMarkerSizeF = 0.03

  txres               = True
  txres@txFontHeightF = 0.010
  txres@txFont        = "helvetica-bold"


;---------------------------
                                   ; Number of points.
  lats  = (/ -16.495,-16.17, -16.48, -16.66, -16.58, -16.40, -17.28, -16.48, -16.50, -16.04, -16.20, -16.45, -15.19, -17.16, -15.83, -17.07, -16.05,  -15.77, -15.53, -15.90, -16.86, -16.59, -17.21, -17.29, -16.90, -17.02, -17.09/)         ; Create some dummy latitude
  lons  = (/ -68.13, -69.09 , -68.14, -68.28, -68.16, -68.47, -68.63, -68.17, -68.12, -69.15, -68.63, -68.09, -69.00, -69.49, -67.57, -69.20, -68.81,  -68.65, -67.25, -68.90, -68.66, -68.97, -69.00, -69.21, -68.21, -68.61, -68.01/)        ; and longitude data that
  R   = (/   59.9,     16.3 , 73.7,     1.8,     15.3,    20.5,    4.0 , 14.6,   39.4, 12.4,     0.1,   20.2,   0.1,     6.6,    25.5,   0.1,   0.1,     18.0,    0.1,    9.5,   14.9,    0.1,    4.5,   5.1,    3.0,     0.1,    0.1/)   ; This is dummy data for determining
                                     ; how to color the markers.
num_distinct_markers = dimsizes(arr)+1        ; number of distinct markers
  lat_new = new((/num_distinct_markers,dimsizes(R)/),float,-999)
  lon_new = new((/num_distinct_markers,dimsizes(R)/),float,-999)

; Group the points according to which range they fall in. At the
; same time, create the label that we will use later in the legend.
;       
  do i = 0, num_distinct_markers-1
    if (i.eq.0) then
      indexes = ind(R.lt.arr(0))
      labels(i) = "x < " + arr(0)
    end if
    if (i.eq.num_distinct_markers-1) then
      indexes = ind(R.ge.max(arr))
      labels(i) = "x >= " + max(arr)
    end if
    if (i.gt.0.and.i.lt.num_distinct_markers-1) then       
      indexes = ind(R.ge.arr(i-1).and.R.lt.arr(i))
      labels(i) = arr(i-1) + " <= x < " + arr(i)
    end if
;
; Now that we have the set of indexes whose values fall within 
; the given range, take the corresponding lat/lon values and store
; them, so later we can color this set of markers with the appropriate
; color.
;
    if (.not.any(ismissing(indexes))) then 
      npts_range = dimsizes(indexes)   ; # of points in this range.
      lat_new(i,0:npts_range-1) = lats(indexes)
      lon_new(i,0:npts_range-1) = lons(indexes)
    end if
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
  end do

  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
  gsres@gsMarkerSizeF = 0.005
  gsres@gsMarkerOpacityF = 0.70
  

  con1 = gsn_csm_contour(wks,hgt(:,:),cres2)
  con2 = gsn_csm_contour(wks,rain1(0,:,:),opts_r)

 ;plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
; Loop through each grouping of markers, and draw them one set at
; a time, assigning the proper color and size with gsn_marker.

  map = gsn_csm_map(wks,mpres)
    dum4=gsn_add_polymarker(wks,map,-68.167,-16.484,mkres)

 lat_start1 = -16.75
  lon_start1 = -68.75
  lat_end1 = -16.33
  lon_end1 = -67.8
line = gsn_add_polyline(wks,map,(/lon_start1,lon_end1/),(/lat_start1,lat_end1/),lnres)
 
txt1=gsn_add_text(wks,map,"La Paz",-68.25,-16.45,txres)
  base_size = 0.0075
  pmid = new(num_distinct_markers,graphic)
  pmidh = new(num_distinct_markers,graphic)
  do i = 0, num_distinct_markers-1
    if (.not.ismissing(lat_new(i,0)))
      gsres@gsMarkerIndex    = 4
      gsres@gsMarkerColor      = colors(i)
      gsres@gsMarkerSizeF      = base_size * (i+1)/3.
      gsres@gsMarkerThicknessF = 0.7*(i+1)
      pmid(i) = gsn_add_polymarker(wks,map,lon_new(i,:),lat_new(i,:),gsres)

   ; gsres@gsMarkerIndex    = 4           ; Hollow dots
   ; gsres@gsMarkerColor    = "black"
   ; pmidh(i) = gsn_add_polymarker(wks,map,lon_new(i,:),lat_new(i,:),gsres)
    
    end if
  end do

   amres                  = True
  amres@amParallelPosF   = 0.131   ; -0.5 is the left edge of the plot.
  amres@amOrthogonalPosF = -0.5   ; -0.5 is the top edge of the plot.
  amres@amJust           = "TopLeft"

  overlay(map,con2)
  overlay(map,con1)
  map_anno = gsn_add_annotation(map, map2, amres)  ; Attach map to map.

 ;overlay(map,prec)
 ;maximize_output(wks,res)
  draw(map)
  frame(wks)
  delete(wks)

 
end