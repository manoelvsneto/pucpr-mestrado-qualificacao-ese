---script para identificao da revisao sistematica.
select convert(int, B.F2),  CONVERT(VARCHAR, B.F1) + ' ' + CONVERT(VARCHAR, B.F2) + ' ' + CONVERT(VARCHAR, B.F3) AS 'Artigo', A.TITLE,A.AUTHORS,
 --A.TITLE + '  Autores:' + A.AUTHORS
 A.ABSTRACT
 from [dbo].[CodeDocumentTable$] B
LEFT JOIN [dbo].[FULL$]  A ON dbo.[FN_FORMATAR_TEXTO]( A.Title ) =   dbo.[FN_FORMATAR_TEXTO]( b.peso) 
 where motivo = 'ENCONTRADO'
--and CODE_SMELL >= 3 and  ( abstract like '%code-smell%' or abstract like '%code smell%' or  title like '%code-smell%' or abstract like '%code smell%' or  title like '%smell%' or abstract like '%smell%' )
--and DATA_SCIENCE_ >= 3 --and  ( abstract like '%mining%' or abstract like '%mining%' or  title like '%mining%' or title like '%mining%')
--and GITHUB > 6 and  ( abstract like '%GITHUB%' or abstract like '%GITHUB%' or  title like '%GITHUB%' or title like '%GITHUB%')
--and CODE_SMELL >= 3 and  ( title like '%sonar%' or abstract like '%sonar%'  )
--and  ( title like '%MSR%' or abstract like '%MSR%'  OR  title like '%MINING SOF%' or abstract like '%MINING SOF%'  )
 ORDER BY convert(int, B.F2)
