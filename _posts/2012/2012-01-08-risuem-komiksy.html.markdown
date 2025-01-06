---
title: "Рисуем комиксы"
date_gmt: '2012-01-08 16:55:08 +0400'
tags:
- Новости
- Алгоритмы
---

Вот и пролетели новогодние праздники...

Все встречают новый год по-разному...

Но можно предположить, что алгоритм "Встречи нового года" у всех примерно такой: застолье, танцы, песни, поздравление близких и друзей...
Вот и я хочу всех поздравить с Новым 2012 годом и процитировать очень запомнившиеся для меня поздравление от Афанасьевой Евгении:  "Успехов вам, проектов интересных, здоровья и любви! :-)

Хочу предложить первый интересный для меня проект - это Cartoon Filter или как я его называю - мультяшный фильтр. Маленькая часть из моего диплома.
<!-- excerpt-end -->
Доступно разъясненный алгоритм было очень сложно найти в интернете, поэтому пришлось поднимать исходники различных проектов с реализацией данного алгоритма. И удача была на моей стороне... Оказывается исходники графического редактора GIMP очень хорошо не только написаны, но и подробно прокомментированы.

Если не верите, то можете смело скачать исходники с официального сайта и найти файл `gimp-2.6.9/plug-ins/common/cartoon.c`. Алгоритм очень простой:

``` c
/*
 * Cartoon algorithm
 * -----------------
 * Mask radius = radius of pixel neighborhood for intensity comparison
 * Threshold   = relative intensity difference which will result in darkening
 * Ramp        = amount of relative intensity difference before total black
 * Blur radius = mask radius / 3.0
 *
 * Algorithm:
 * For each pixel, calculate pixel intensity value to be: avg (blur radius)
 * relative diff = pixel intensity / avg (mask radius)
 * If relative diff < Threshold
 *   intensity mult = (Ramp - MIN (Ramp, (Threshold - relative diff))) / Ramp
 *   pixel intensity *= intensity mult
 */
```

Моя первая реализация алгоритма:

``` c
void ComicsFilter::cartoon(QImage *image){

    double size = m_mask_radius * m_mask_radius;

    int center = m_mask_radius / 2 + 1,
            width = m_image->width() - center,
            height = m_image->height() - center,
            top = m_mask_radius / 2;

    for(int x = center; x < width; ++x)
        for(int y = center; y < height; ++y){

            int i = 0;
            double sumR = 0, sumB = 0, sumG = 0;
            for(int iX = x-top; i < m_mask_radius; ++i,++iX){

                int j = 0;
                for(int iY = y-top; j < m_mask_radius; ++j,++iY){

                    sumR += qRed(m_image->pixel(iX,iY));
                    sumB += qBlue(m_image->pixel(iX,iY));
                    sumG += qGreen(m_image->pixel(iX,iY));
                }
            }

            sumR /= size;
            sumB /= size;
            sumG /= size;

            //image->setPixel(x,y,qRgb(sumR,sumB,sumG));

            double red = qRed(m_image->pixel(x,y)),
                    blue = qBlue(m_image->pixel(x,y)),
                    green = qGreen(m_image->pixel(x,y));

            double koeffR = red / sumR,
                    koeffB = blue / sumB,
                    koeffG = green / sumG;

            if(koeffR < m_threshold)
                red *= ((m_ramp - qMin(m_ramp,(m_threshold - koeffR)))/m_ramp);


            if(koeffB < m_threshold)
                blue *= ((m_ramp - qMin(m_ramp,(m_threshold - koeffB)))/m_ramp);


            if(koeffG < m_threshold)
                green *= ((m_ramp - qMin(m_ramp,(m_threshold - koeffG)))/m_ramp);

            image->setPixel(x,y,qRgb(red,green,blue));
        }
}
```

За основу подойдет любой сглаживающий фильтр. В моем примере я взял [усредненный фильтр](http://www.pcigeomatics.com/cgi-bin/pcihlp/IWORKS%7CFilter%7CAverage+Filter), а программисты GIMP используют фильтр Гаусса. Фильтром Гаусса сначало идут по столбцам, а затем по строкам и благодаря двум проходам автоматически вычисляют коэффициент затемнения dump:

``` c
/**
  @param dest1 по столбцам
  @param dest2 по строкам
  @param length размер изображения (width*height)
  @param pct_black процент затемнения
*/
static gdouble
compute_ramp (guchar  *dest1,
              guchar  *dest2,
              gint     length,
              gdouble  pct_black)
{
  gint    hist[100];
  gdouble diff;
  gint    count;
  gint    i;
  gint    sum;

  memset (hist, 0, sizeof (int) * 100);
  count = 0;

  for (i = 0; i < length; i++)
    {
      if (*dest2 != 0)
        {
          diff = (gdouble) *dest1 / (gdouble) *dest2;
          if (diff < 1.0)
            {
              hist[(int) (diff * 100)] += 1;
              count += 1;
            }
        }

      dest1++;
      dest2++;
    }

  if (pct_black == 0.0 || count == 0)
    return 1.0;

  sum = 0;
  for (i = 0; i < 100; i++)
    {
      sum += hist[i];
      if (((gdouble) sum / (gdouble) count) > pct_black)
        return (1.0 - (gdouble) i / 100.0);
    }

  return 0.0;
}

```

Если немножко заглянуть в будущее, то данный алгоритм переведу на CUDA, думаю это не должно вызвать сложностей, ведь реализации фильтра Гаусса и фильтра с использованием ядра можно найти в примерах CUDA SDK, а также "мультяшный" фильтр попробуем применить к видео файлам.

Предлагаю посмотреть на реализацию данного алгоритма. Cartoon filter с параметрами: radius = 23, threshold = 1.0, ramp = 0.15. Если приловчиться с входными параметрами, то можно сделать очень забавные комиксы :-)

![Исходное изображение](/posts/2012/01-08-risuem-komiksy/car.jpeg)

![Исходное изображение](/posts/2012/01-08-risuem-komiksy/cartoon_car.jpeg)
