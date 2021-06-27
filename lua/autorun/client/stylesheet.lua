﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.

BrandColorGrayDarker = Color(32, 32, 32) --(26, 30, 38)
BrandColorGrayDark = Color(48, 48, 48) --(38, 41, 49)
BrandColorGray = Color(69, 69, 69)
BrandColorGrayLight = Color(144, 144, 144)
BrandColorWhite = Color(255, 255, 255)
BrandColorPrimary = Color(104, 28, 25)
BrandColorAlternate = Color(40, 96, 104) --Color(36, 56, 26) --Color(40, 96, 104)

-- 24381a
--[[
@gray-base:              #000;
@gray-darker:            #222;
@gray-dark:              #333;
@gray:                   #454545;
@gray-light:             #999;
@gray-lighter:           #EBEBEB;

@brand-primary:         #206068;
@brand-success:         #10c090;
@brand-info:            #3498DB;
@brand-warning:         #F39C12;
@brand-danger:          #E74C3C;
]]
--10c090
function BrandBackgroundPattern(x, y, w, h, px, special)
    surface.SetDrawColor(BrandColorPrimary)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(0, 0, 0, 40)
    draw.NoTexture()
    local stripewidth = 20
    local stripepos = -(px % (2 * stripewidth))

    if special then
        stripepos = stripepos - stripewidth
    end

    while stripepos < w + h do
        local triangle = {
            {
                x = x + stripepos,
                y = y
            },
            {
                x = x + stripepos + stripewidth,
                y = y
            },
            {
                x = x + stripepos + stripewidth - h,
                y = y + h
            },
            {
                x = x + stripepos - h,
                y = y + h
            }
        }

        surface.DrawPoly(triangle)
        stripepos = stripepos + (2 * stripewidth)
    end
end

function BrandDropDownGradient(x, y, w)
    draw.GradientShadowDown(x, y, w, 8, 0.65)
end

BrandTitleBarHeight = 64

surface.CreateFont("LabelFont", {
    font = "Lato-Light",
    size = 21,
    weight = 200
})

surface.CreateFont("SmallFont", {
    font = "Lato",
    size = 16,
    weight = 200
})