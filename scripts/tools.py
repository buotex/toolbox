import numpy as np
import vigra
import itertools
def overlay2RGBimgs(img1,img2,alpha=0.6):
    #print img1.shape,img2.shape
    img1=np.require(img1,np.float32)
    img2=np.require(img2,np.float32)

    assert img1.shape==img2.shape
    #assert img1.ndim==3,img1.ndim
    #assert img1.shape[-1]==3
    img1t=np.where(img2!=0,img1*(1-alpha)+alpha*img2,img1)
    return img1t.astype(np.uint8)
    #return img1*(1-alpha)+alpha*img2



def overlaySegmentationContuors(img,labels,radius=1):
    edge=vigra.analysis.regionImageToEdgeImage(labels,1)*255
    edge=edge.view(np.ndarray).astype(np.uint8)
    edge=vigra.filters.discDilation(edge, radius=radius)
    edge=np.dstack([edge,np.zeros(edge.shape),np.zeros(edge.shape)])
    return overlay2RGBimgs(img,edge,alpha=1)

def overlaySegments2D(img2d,limg,alpha=0.5,palette=None):
    """ Overlay the limag segmentation to the original img

    Parameters
    ----------
    img2d : 2d img gray or rgb

    limg  : 2d labelled img,
            segmentation zeros will be transparent

    alpha : float alpha value
    palette : the palette to be used

    Returns
    -------
    overlay : rgb img


    """

    maximum = np.max(limg)
    if palette==None:
        from good_palette_dark100 import palette
        palette = [pal for i, pal in zip(range(maximum + 1),itertools.cycle(palette) )]
        palette=np.vstack(palette)
        palette=np.vstack(([0,0,0],palette))
    else:
        raise NotImplementedError
    assert img2d.shape[0]==limg.shape[0]
    assert img2d.shape[1]==limg.shape[1]

    r=palette[:,0]
    r=r[limg.astype(np.uint32)]
    g=palette[:,1]
    g=g[limg.astype(np.uint32)]
    b=palette[:,2]
    b=b[limg.astype(np.uint32)]

    coloredimg=np.dstack((r,g,b))



    if img2d.ndim==3:
        assert img2d.shape[-1]==3
        img2drgb=np.copy(img2d)
    else:
        img2drgb=np.dstack([img2d,img2d,img2d])
    img2drgb=overlay2RGBimgs(img2drgb,coloredimg, alpha)

    return img2drgb.astype(np.uint8)
