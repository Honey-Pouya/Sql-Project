USE [master]
GO
/****** Object:  Database [Election]    Script Date: 6/8/2016 4:18:08 PM ******/
CREATE DATABASE [Election] ON  PRIMARY 
( NAME = N'master', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Elction.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'mastlog', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Election_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Election].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [Election] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Election] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Election] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Election] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Election] SET ARITHABORT OFF 
GO
ALTER DATABASE [Election] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Election] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Election] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Election] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Election] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Election] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Election] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Election] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Election] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Election] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Election] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Election] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Election] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Election] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Election] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Election] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Election] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Election] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Election] SET  MULTI_USER 
GO
ALTER DATABASE [Election] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Election] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Election', N'ON'
GO
ALTER AUTHORIZATION ON DATABASE::[Election] TO [Scopion-pc\Scorpion]
GO
USE [Election]
GO
/****** Object:  User [##MS_PolicyEventProcessingLogin##]    Script Date: 6/8/2016 4:18:08 PM ******/
CREATE USER [##MS_PolicyEventProcessingLogin##] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  StoredProcedure [dbo].[delete_student]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delete_student]
@stu_id int


AS
BEGIN
if not exists (select *from student where id_stu=@stu_id)
return 0

else
delete from profile
where id_stu=@stu_id
return 1


END
GO
ALTER AUTHORIZATION ON [dbo].[delete_student] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[disable_student]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[disable_student]
@stu_id int,
@enable bit

AS
BEGIN
if not exists (select *from student where id_stu=@stu_id)
return 0

else
update student set EnableState=@enable
where id_stu=@stu_id
return 1


END

GO
ALTER AUTHORIZATION ON [dbo].[disable_student] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[FindUserPass]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FindUserPass]
  @id int,
  @pass nvarchar(50) output
as
if not exists ( select * from profile where id_stu=@id )
return 0

set @pass=( select pass from profile where id_stu=@id )
return 1
GO
ALTER AUTHORIZATION ON [dbo].[FindUserPass] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[insert_ara_to_candid]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[insert_ara_to_candid]

AS
BEGIN
 update Candidate set TedadAra=vote_result.tedad_ara
from Candidate inner join vote_result
on Candidate.id_stu=vote_result.id_cand and Candidate.id_club=vote_result.id_club
END

GO
ALTER AUTHORIZATION ON [dbo].[insert_ara_to_candid] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[ret_dabir_club]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ret_dabir_club]
  
AS
BEGIN
select MAX(tedad_ara)as maxara into #max_ara_all_club
 from (select COUNT(*)as tedad_ara,id_club from dbo.vote
group by id_cand,id_club)as tmp1
group by id_club
 

select tedad_ara,id_cand,id_club into #non_final_result
 from  dbo.vote_result inner join #max_ara_all_club on #max_ara_all_club.maxara=vote_result.tedad_ara

 select name,family,id_cand,tedad_ara,case id_club 
  when 17 then N'دبیر انجمن کشاورزی'
 when 46 then N'دبیر انجمن کامپیوتر'
 end as 'انجمن'
 from student inner join #non_final_result 
  on #non_final_result.id_cand=id_stu

END

GO
ALTER AUTHORIZATION ON [dbo].[ret_dabir_club] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[update_student]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[update_student]
@stu_id int,
@name nvarchar(100),
@family nvarchar(100)
AS
BEGIN
if not exists (select *from student where id_stu=@stu_id)
return 0

else
update student set name=@name,family=@family
where id_stu=@stu_id
return 1
END

GO
ALTER AUTHORIZATION ON [dbo].[update_student] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[chk]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[chk](@id_club char(2),@id_stu char(10))
RETURNS int
as
BEGIN
DECLARE @Result int
DECLARE @Master int
DECLARE @old_club int
DECLARE @roll_notroll int
SET @Result=(select count(id_stu) from profile where id_stu=@id_stu)

 IF(@Result=2) 
  BEGIN
  set @Master=(select master_notmaster from club inner join profile on profile.id_club=club.id_club where id_stu=@id_stu and profile.id_club=@id_club)
 IF(@Master=1)
 BEGIN
 set @old_club=(select master_notmaster from club inner join profile on profile.id_club=club.id_club where id_stu=@id_stu and profile.id_club!=@id_club)
 if(@old_club=1)
  BEGIN
  set @roll_notroll=1
  END
 END
  END
  IF(@Result=3) 
  BEGIN
   set @roll_notroll=1
  END
  RETURN @roll_notroll
END

GO
ALTER AUTHORIZATION ON [dbo].[chk] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[cnt]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[cnt](@id_club char(2))
RETURNS int
as
BEGIN
DECLARE @number int
DECLARE @Result int
  set @number=(select count(news.id_club) from news where id_club=@id_club)

IF (@number>4 )
BEGIN
    SET @Result = 1
END
ELSE 
BEGIN
    SET @Result = 0
END

RETURN @Result
END
GO
ALTER AUTHORIZATION ON [dbo].[cnt] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[equal]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[equal](@id_club char(2),@id_stu char(10))
RETURNS int
as
BEGIN
DECLARE @Result int
DECLARE @Master int
  set @Master=(select master_notmaster from club inner join profile on profile.id_club=club.id_club where id_stu=@id_stu and profile.id_club=@id_club)

IF (NOT EXISTS(select id_stu from profile where (id_stu like '__' + @id_club + '%') and id_stu=@id_stu) and(@Master=1) )
BEGIN
    SET @Result = 1
END
ELSE 
BEGIN
    SET @Result = 0
END

RETURN @Result
END
GO
ALTER AUTHORIZATION ON [dbo].[equal] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[link_chk]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[link_chk](@link_add varchar(MAX))
RETURNS int
as
BEGIN
--DECLARE @number int
DECLARE @Result int
  --set @number=(select count(news.id_club) from news where id_club=@id_club)

IF (@link_add like 'https'+'%' )
BEGIN
    SET @Result = 1
END
ELSE 
BEGIN
    SET @Result = 0
END

RETURN @Result
END
GO
ALTER AUTHORIZATION ON [dbo].[link_chk] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[ret_data_type]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ret_data_type](@tb varchar(150),@col varchar(150) )
RETURNS NVARCHAR(MAX)
BEGIN
    RETURN (select Data_Type from INFORMATION_SCHEMA.COLUMNS where Table_Name=@tb and Column_Name=@col)
END
GO
ALTER AUTHORIZATION ON [dbo].[ret_data_type] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[stu_nationalcod_chk]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[stu_nationalcod_chk](@national_cod char(10))
RETURNS int
as
BEGIN
--DECLARE @number int
DECLARE @Result int
  --set @number=(select count(news.id_club) from news where id_club=@id_club)

IF (LEN(@national_cod) <10)
BEGIN
    SET @Result = 1
END
ELSE 
BEGIN
    SET @Result = 0
END

RETURN @Result
END
GO
ALTER AUTHORIZATION ON [dbo].[stu_nationalcod_chk] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Candidate]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Candidate](
	[id_term] [int] NOT NULL,
	[id_stu] [int] NOT NULL,
	[avrage] [money] NOT NULL,
	[id_club] [int] NOT NULL,
	[StartDate] [nchar](10) NOT NULL,
	[EndDate] [nchar](10) NOT NULL,
	[TedadAra] [int] NULL,
 CONSTRAINT [PK_Candidate] PRIMARY KEY CLUSTERED 
(
	[id_term] ASC,
	[id_stu] ASC,
	[id_club] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER AUTHORIZATION ON [dbo].[Candidate] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[club]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[club](
	[id_club] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[flag] [bit] NOT NULL,
	[startDate] [char](10) NOT NULL,
	[pic] [image] NULL,
	[master_notmaster] [bit] NULL,
 CONSTRAINT [PK_club] PRIMARY KEY CLUSTERED 
(
	[id_club] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER AUTHORIZATION ON [dbo].[club] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[link]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[link](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_club] [int] NOT NULL,
	[text_title] [nvarchar](256) NOT NULL,
	[link_add] [varchar](max) NOT NULL,
 CONSTRAINT [PK_link_1] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER AUTHORIZATION ON [dbo].[link] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[manager]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[manager](
	[nationalcode] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[pass] [nvarchar](50) NOT NULL,
	[flag] [bit] NOT NULL,
	[start_date] [char](10) NOT NULL,
 CONSTRAINT [PK_manager] PRIMARY KEY CLUSTERED 
(
	[nationalcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER AUTHORIZATION ON [dbo].[manager] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[news]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[news](
	[id_club] [int] NOT NULL,
	[flag] [bit] NOT NULL,
	[pic] [image] NULL,
	[date] [varchar](50) NOT NULL,
	[titr] [nvarchar](256) NULL,
	[id_news] [int] IDENTITY(1,1) NOT NULL,
	[text] [ntext] NULL,
 CONSTRAINT [PK_news] PRIMARY KEY CLUSTERED 
(
	[id_club] ASC,
	[id_news] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER AUTHORIZATION ON [dbo].[news] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[profile]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[profile](
	[id_stu] [int] NOT NULL,
	[pass] [nvarchar](50) NOT NULL,
	[username] [nvarchar](50) NOT NULL,
	[pic] [image] NULL,
	[email] [varchar](50) NULL,
	[id_club] [int] NOT NULL,
	[EnableState] [bit] NOT NULL,
	[semat] [bit] NULL,
 CONSTRAINT [PK_profile] PRIMARY KEY CLUSTERED 
(
	[id_stu] ASC,
	[id_club] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER AUTHORIZATION ON [dbo].[profile] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[publication]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[publication](
	[id_pub] [int] IDENTITY(1,1) NOT NULL,
	[id_club] [int] NOT NULL,
	[File] [image] NOT NULL,
	[flag] [bit] NOT NULL,
	[date] [char](10) NOT NULL,
 CONSTRAINT [PK_publication] PRIMARY KEY CLUSTERED 
(
	[id_pub] ASC,
	[id_club] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER AUTHORIZATION ON [dbo].[publication] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[student]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[student](
	[id_stu] [int] NOT NULL,
	[national_code] [char](10) NOT NULL,
	[name] [nvarchar](50) NULL,
	[family] [nvarchar](50) NULL,
	[EnableState] [bit] NOT NULL,
 CONSTRAINT [PK_student] PRIMARY KEY CLUSTERED 
(
	[id_stu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER AUTHORIZATION ON [dbo].[student] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[veiw]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[veiw](
	[srl] [int] IDENTITY(1,1) NOT NULL,
	[date] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_veiw] PRIMARY KEY CLUSTERED 
(
	[srl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER AUTHORIZATION ON [dbo].[veiw] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[vote]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[vote](
	[id_stu] [int] NOT NULL,
	[id_cand] [int] NOT NULL,
	[id_club] [int] NOT NULL,
	[id_term] [int] NOT NULL,
 CONSTRAINT [PK_vote] PRIMARY KEY CLUSTERED 
(
	[id_stu] ASC,
	[id_cand] ASC,
	[id_club] ASC,
	[id_term] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER AUTHORIZATION ON [dbo].[vote] TO  SCHEMA OWNER 
GO
/****** Object:  View [dbo].[club_members]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[club_members]
AS
SELECT        tmp.stu_family, tmp.stu_name, tmp.stu_id, dbo.club.name AS anjoman_marbooteh, tmp.anjoman_id
FROM            dbo.club INNER JOIN
                             (SELECT        dbo.student.name AS stu_name, dbo.student.family AS stu_family, dbo.student.id_stu AS stu_id, 
                                                         dbo.profile.id_club AS anjoman_id
                               FROM            dbo.student INNER JOIN
                                                         dbo.profile ON dbo.student.id_stu = dbo.profile.id_stu) AS tmp ON dbo.club.id_club = tmp.anjoman_id


GO
ALTER AUTHORIZATION ON [dbo].[club_members] TO  SCHEMA OWNER 
GO
/****** Object:  View [dbo].[members_notmembers]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[members_notmembers] as
select student.name,student.family,student.id_stu,case   
  WHEN anjoman_marbooteh IS NULL THEN N'عضو نمی باشد'
         else N'عضو '+ anjoman_marbooteh + ' ' + N'می باشد'
        END as N'ozviyat'
from student left join club_members
 on id_stu=stu_id



GO
ALTER AUTHORIZATION ON [dbo].[members_notmembers] TO  SCHEMA OWNER 
GO
/****** Object:  View [dbo].[ClubState]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[ClubState] as
SELECT  id_club as shomareh_Anjoman, name as nameanjoman,case flag 
when 1 then N'فعال است'
when 0 then N'غیر فعال است'
end as State
FROM dbo.club





GO
ALTER AUTHORIZATION ON [dbo].[ClubState] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[ClubState_fun]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ClubState_fun](@vaziyat nvarchar(30) )
RETURNS table
AS
RETURN (
        SELECT * FROM ClubState
        WHERE dbo.ClubState.State = @vaziyat
       )
GO
ALTER AUTHORIZATION ON [dbo].[ClubState_fun] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[club_members_fun]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[club_members_fun](@club_name nvarchar(100))
RETURNS table
AS
RETURN (
        SELECT anjoman_marbooteh,COUNT(dbo.club_members.stu_id)as tedad_ozv FROM dbo.club_members
        WHERE dbo.club_members.anjoman_marbooteh = @club_name
	group by anjoman_marbooteh
       )
GO
ALTER AUTHORIZATION ON [dbo].[club_members_fun] TO  SCHEMA OWNER 
GO
/****** Object:  View [dbo].[count_members_of_club]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[count_members_of_club] as
select anjoman_marbooteh,count(stu_id) as tedade_aza from
(select tmp.stu_family,tmp.stu_name,tmp.stu_id ,club.name as anjoman_marbooteh from 
club,(select student.name as stu_name,student.family as stu_family ,student.id_stu as stu_id,id_club as anjoman_id
from student,profile
where student.id_stu=profile.id_stu
)as tmp 
where tmp.anjoman_id=club.id_club)as tmp2
group by anjoman_marbooteh



GO
ALTER AUTHORIZATION ON [dbo].[count_members_of_club] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[count_members_of_club_fun]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[count_members_of_club_fun](@name nvarchar(100))
RETURNS table
AS
RETURN (
        SELECT tedade_aza FROM dbo.count_members_of_club
        WHERE dbo.count_members_of_club.anjoman_marbooteh = @name
       )
GO
ALTER AUTHORIZATION ON [dbo].[count_members_of_club_fun] TO  SCHEMA OWNER 
GO
/****** Object:  UserDefinedFunction [dbo].[members_notmembers_fun]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[members_notmembers_fun](@sale_vorood nvarchar(50),@ozv nvarchar(50))
RETURNS table
AS
RETURN (
select name,family,id_stu,ozviyat from dbo.members_notmembers 
where id_stu like @sale_vorood +'%'  and ozviyat like '%'+ @ozv + '%'

)
GO
ALTER AUTHORIZATION ON [dbo].[members_notmembers_fun] TO  SCHEMA OWNER 
GO
/****** Object:  View [dbo].[vote_result]    Script Date: 6/8/2016 4:18:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vote_result] as
select COUNT(*)as tedad_ara,id_cand,id_club from dbo.vote
group by id_cand,id_club




GO
ALTER AUTHORIZATION ON [dbo].[vote_result] TO  SCHEMA OWNER 
GO
INSERT [dbo].[Candidate] ([id_term], [id_stu], [avrage], [id_club], [StartDate], [EndDate], [TedadAra]) VALUES (1, 91170124, 16.5000, 17, N'11/6/2015 ', N'13/6/2015 ', 4)
INSERT [dbo].[Candidate] ([id_term], [id_stu], [avrage], [id_club], [StartDate], [EndDate], [TedadAra]) VALUES (1, 91170125, 16.8000, 17, N'11/6/2015 ', N'13/6/2015 ', 4)
INSERT [dbo].[Candidate] ([id_term], [id_stu], [avrage], [id_club], [StartDate], [EndDate], [TedadAra]) VALUES (1, 92462101, 17.0000, 46, N'11/6/2015 ', N'13/6/2015 ', 10)
INSERT [dbo].[Candidate] ([id_term], [id_stu], [avrage], [id_club], [StartDate], [EndDate], [TedadAra]) VALUES (1, 92462105, 15.0000, 41, N'11/6/9898 ', N'13/5/5898 ', NULL)
INSERT [dbo].[Candidate] ([id_term], [id_stu], [avrage], [id_club], [StartDate], [EndDate], [TedadAra]) VALUES (1, 92462114, 16.0000, 46, N'11/6/2105 ', N'13/6/2015 ', 1)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (1, N'معاونت', 1, N'5/20/2015 ', NULL, 1)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (17, N'کشاورزی', 0, N'5/20/2015 ', NULL, 1)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (41, N'نقشه برداری', 1, N'5/20/2015 ', NULL, 1)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (43, N'معماری', 0, N'5/20/2015 ', NULL, 1)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (46, N'کامپیوتر', 1, N'5/20/2015 ', NULL, 1)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (47, N'برق', 1, N'5/20/2015 ', NULL, 1)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (48, N'مکانیک', 1, N'5/20/2015 ', NULL, 1)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (88, N'نقشه_معماری', 1, N'20/5/2015 ', NULL, 0)
INSERT [dbo].[club] ([id_club], [name], [flag], [startDate], [pic], [master_notmaster]) VALUES (89, N'مکاترونیک', 1, N'5/20/2015 ', NULL, 0)
SET IDENTITY_INSERT [dbo].[link] ON 

INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (1, 1, N'سایت خبری', N'https://news.znu.ac.ir/')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (2, 1, N'فود', N'https://food.znu.ac.ir/')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (3, 46, N'سیویلیکا', N'https://www.civilica.com/Paper-WRM04-WRM04_157.html')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (4, 46, N'لینکدین', N'https://linkedin.com/')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (6, 46, N'انجمن کامپیوتر ایران', N'https://csi.org.ir/')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (7, 46, N'انجمن علمی کامپیوتر صنعتی اصفهان', N'https://cessa.iut.ac.ir/pages/index.html')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (9, 43, N'معماری سنتی ایرانی', N'https://hotspot2.znu.ac.ir/login?dst=https%3A%2F%2Fwww.msftncsi.com%2Fredirect')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (10, 43, N'معماران نوین', N'https://stackoverflow.com/questions/3453151/notepad-multi-editing')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (11, 17, N'کشاورزان ارگانیک', N'https://notepad-plus-plus.org/features/multi-editing.html')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (12, 17, N'کشاورزکار', N'https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=5&sqi=2&ved=0CDkQFjAEahUKEwjho5mZ98jIAhUFSBQKHdYnAc4&url=http%3A%2F%2Finside.mines.edu%2F~whoff%2Fcourses%2FEENG510%2Flectures%2F04-InterpolationandSpatialTransforms.pdf&usg=AFQjCNHuz4VZYAw3RdLKnhUrZtsiN6sK2g&bvm=bv.105454873,d.bGQ&cad=rja')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (13, 41, N'نقشه برداران جوان', N'https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=5&sqi=2&ved=0CDkQFjAEahUKEwjho5mZ98jIAhUFSBQKHdYnAc4&url=http%3A%2F%2Finside.mines.edu%2F~whoff%2Fcourses%2FEENG510%2Flectures%2F04-InterpolationandSpatialTransforms.pdf&usg=AFQjCNHuz4VZYAw3RdLKnhUrZtsiN6sK2g&bvm=bv.105454873,d.bGQ&cad=rja')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (14, 48, N'مکانیک ایران', N'https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=5&sqi=2&ved=0CDkQFjAEahUKEwjho5mZ98jIAhUFSBQKHdYnAc4&url=http%3A%2F%2Finside.mines.edu%2F~whoff%2Fcourses%2FEENG510%2Flectures%2F04-InterpolationandSpatialTransforms.pdf&usg=AFQjCNHuz4VZYAw3RdLKnhUrZtsiN6sK2g&bvm=bv.105454873,d.bGQ&cad=rja')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (15, 48, N'مکانیک سرا', N'https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=5&sqi=2&ved=0CDkQFjAEahUKEwjho5mZ98jIAhUFSBQKHdYnAc4&url=http%3A%2F%2Finside.mines.edu%2F~whoff%2Fcourses%2FEENG510%2Flectures%2F04-InterpolationandSpatialTransforms.pdf&usg=AFQjCNHuz4VZYAw3RdLKnhUrZtsiN6sK2g&bvm=bv.105454873,d.bGQ&cad=rja')
INSERT [dbo].[link] ([id], [id_club], [text_title], [link_add]) VALUES (16, 48, N'مکاترونیکی ها', N'https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=5&sqi=2&ved=0CDkQFjAEahUKEwjho5mZ98jIAhUFSBQKHdYnAc4&url=http%3A%2F%2Finside.mines.edu%2F~whoff%2Fcourses%2FEENG510%2Flectures%2F04-InterpolationandSpatialTransforms.pdf&usg=AFQjCNHuz4VZYAw3RdLKnhUrZtsiN6sK2g&bvm=bv.105454873,d.bGQ&cad=rja')
SET IDENTITY_INSERT [dbo].[link] OFF
INSERT [dbo].[manager] ([nationalcode], [name], [pass], [flag], [start_date]) VALUES (439956879, N'حسین', N'حمزه لو', 1, N'10/17/2015')
SET IDENTITY_INSERT [dbo].[news] ON 

INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (17, 1, NULL, N'05 / 13 / 2015', N'کشاورزی ارگانیک چیست', 8, N'مراحی از تمامی  این کارهاییی را که باید')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (41, 1, NULL, N'03 / 23 / 2015', N'ورود نقشه برداران به المپیک', 16, N'ورد جوانان نقشه برداران دانشگاه زنجان ...')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (43, 1, NULL, N'11/ 23 / 2015', N'جایگاه معماری ایرانی در جهان', 11, N'معماری ایرانی در جهان دارای جایگاهی بس والا می باشد که ....')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (43, 1, NULL, N'06 / 03 / 2015', N'معماران برتر', 13, NULL)
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (43, 1, NULL, N'05 / 23 / 2015', N'معمار آکادمیک کیست', 15, N'معماری آکادمیک اصولا به افراد اطلاق می شود که اگر...')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (46, 1, NULL, N'05 / 20 / 2015', N'پدر علم کامپیوتر عوض شد', 4, N'منظور از پدر علم کامپیوتر در قدیم در شاخه ی هوش مصنوعی فردی بود به نام تورینگ ه ...')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (46, 1, NULL, N'05 / 20 / 2015', N'پردازنده های مافوق صوت', 5, N'آیا این ایده که پردازنده های مافوق صوت در برخی کشورها عرضه خاهد شد ز سوی شکرت هایی چون اپل و ..')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (46, 1, NULL, N'05 / 20 / 2015', N'کامپیوترهای کوانتومی ارزان', 6, N'این دیدگاه که  در آینده کامپیوتر های کوانتومی ارزان قیمت وجود داشته باشند مورد بررسی قرار گرفت و با موافقت خیلی از افراد مواجه شده است')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (46, 1, NULL, N'05 / 23 / 2015', N'راهیابی دانشجوی دانشگاه زنجان به مسابقات جهانی', 7, N'دانشجوی مهندسی کامپیوتر دانشگاه زنجان ب تلاش بی شاعبه توانست  در مسابقات برنامه نویسیس که در کشور...')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (48, 1, NULL, N'10 / 24/ 2015', N'مکانیک سیالت دکتر اهورایی به چاپ رسید', 9, N'در این هفته انشجویان دانشگاه زنجان با خرید تعداد زیادی از این نسخه های اولیه کتاب')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (48, 1, NULL, N'9 / 29 / 2015', N'پزوهشکده ی مکانیک', 10, N'افتتاح اولین پزوهشکده ی علمی و فنی مکانیک در سراسر کشور')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (48, 1, NULL, N'64646', N'kju', 27, N'bjjbj')
INSERT [dbo].[news] ([id_club], [flag], [pic], [date], [titr], [id_news], [text]) VALUES (48, 1, NULL, N'khibu', N'hihuih', 28, N'ihiuhi')
SET IDENTITY_INSERT [dbo].[news] OFF
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91170124, N'123456', N'beh', NULL, NULL, 17, 1, 1)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91170125, N'321', N'al', NULL, NULL, 17, 0, 1)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91170126, N'3649896', N',sfjeghioreg', NULL, NULL, 17, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91170127, N'3164996', N'fhruthrt', NULL, NULL, 17, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91170128, N'1236588', N'wndkjfeo', NULL, NULL, 17, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91414105, N'2185884', N'jkhgft', NULL, NULL, 41, 0, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91414106, N'9466659', N'oihugfydt', NULL, NULL, 41, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91414107, N'hvjbk', N'chvjbk', NULL, NULL, 41, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91414108, N'6194946', N'tyfghojhiu', NULL, NULL, 41, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91414109, N'2198484', N'fyghjoigf', NULL, NULL, 41, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91432110, N'1649459', N';jhgt5s4a', NULL, NULL, 43, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91432127, N'6494913', N'fghigfds5fy', NULL, NULL, 43, 0, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91432128, N'6194946', N'khuf5s4t7', NULL, NULL, 43, 0, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91462106, N'ohgfus6yg', N'lhkgfutdr', NULL, NULL, 46, 0, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91462129, N',ll', N'khjhgf', NULL, NULL, 46, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91484801, N'rtdyfugi', N'tytfygu', NULL, NULL, 48, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91484802, N'rtyfghou', N'yuihouiuf', NULL, NULL, 48, 0, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91484804, N'tyfghjjoi', N'tchkgouou', NULL, NULL, 48, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91484805, N';kgjxzre', N'jlhkgfidz5', NULL, NULL, 48, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91484806, N'ytchvjbnoi', N'toig87f86', NULL, NULL, 48, 1, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (91484807, N'poyitds635a', N'uyfughpi', NULL, NULL, 48, 0, 0)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (92462101, N'mey', N'123', NULL, NULL, 46, 1, 1)
INSERT [dbo].[profile] ([id_stu], [pass], [username], [pic], [email], [id_club], [EnableState], [semat]) VALUES (92462101, N'kk', N'kj', NULL, NULL, 88, 1, 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170124, N'0632598568', N'behrooz', N'mahmoodi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170125, N'0632335875', N'alireza', N'ghiyasvan', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170126, N'0298746598', N'mohammad', N'afshar', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170127, N'0965821456', N'yazdan', N'mohammadi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170128, N'0396587459', N'nader', N'bohloli', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170129, N'0385630145', N'reza', N'asghari', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170130, N'0965895486', N'farid', N'abbasi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170131, N'0875965488', N'hamed', N'yoosefi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170132, N'0698547856', N'behzad', N'jalali', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91170133, N'0396587965', N'mojtaba', N'asl', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414105, N'0635879545', N'mohammad', N'bahrami', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414106, N'0423659878', N'saber', N'rezayi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414107, N'0398586984', N'naser', N'azad', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414108, N'0325615623', N'reza', N'fayyaz', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414109, N'0493569214', N'ali', N'sadri', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414110, N'1646464946', N'taher', N'azimi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414111, N'0326598575', N'abbas', N'ghanbari', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414112, N'0361549102', N'behrooz', N'cheraghpoor', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414119, N'0256985469', N'hossein', N'ghaffari', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91414123, N'0256987456', N'saeed', N'fallah', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432110, N'0659874569', N'arshiya', N'akhavan', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432127, N'0365984576', N'mahan', N'ghazanfari', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432128, N'0365987586', N'mahdi', N'rezaii', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432129, N'0256985569', N'sadegh', N'asadi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432130, N'0258963147', N'hamid', N'ghani', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432131, N'0265987456', N'saeed', N'debazar', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432132, N'0213652398', N'davood', N'azari', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432133, N'0569847512', N'farshid', N'sadeghi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432134, N'0336598878', N'hamed', N'safari', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91432135, N'0195862347', N'saber', N'ahmadi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91462105, N'0569874598', N'farshad', N'pirhadi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91462106, N'0325698548', N'mehdi', N'habibzadehsde', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91462127, N'0598684789', N'moosa', N'mir', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91462129, N'0935265489', N'farhad', N'linixedrresdvsdvdsv', 0)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91463108, N'0256665692', N'soroosh', N'poorabdi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484801, N'0236598589', N'hiva', N'moradi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484802, N'0365987455', N'ali', N'nasiri', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484803, N'0236145269', N'reza', N'noroozi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484804, N'0369887589', N'aslan', N'bagheri', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484805, N'0365998457', N'heydar', N'alimi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484806, N'0266598566', N'bahador', N'abedini', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484807, N'0326546251', N'amir', N'chabok', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484808, N'0255983214', N'bbmood', N'mohseni', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484809, N'0367981156', N'ali', N'dehghan', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (91484810, N'0995785456', N'zafar', N'abbasi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (92462101, N'0439958657', N'meysam', N'esfandiyari', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (92462105, N'0456589545', N'vahid', N'taghizad', 0)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (92462114, N'0296854759', N'hasan', N'fathi', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (92462119, N'3265932325', N'ljih8', N'hjgu', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (92462122, N'0469358745', N'mehdi', N'mamashli', 1)
INSERT [dbo].[student] ([id_stu], [national_code], [name], [family], [EnableState]) VALUES (92462123, N'0362895478', N'salar', N'moosavi', 1)
SET IDENTITY_INSERT [dbo].[veiw] ON 

INSERT [dbo].[veiw] ([srl], [date]) VALUES (2, N'1')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3, N'12')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (4, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (6, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (7, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (8, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (9, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (10, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (11, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (12, N'5 / 19 / 2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (13, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (14, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (15, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (16, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (17, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (18, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (19, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (20, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (21, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (22, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (23, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (24, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (25, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (26, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (27, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (28, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (29, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (30, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (31, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (32, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (33, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (34, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (35, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (36, N'5 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (37, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (38, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (39, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (40, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (41, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (42, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (43, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (44, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (45, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (46, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (47, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (48, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (49, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (50, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (51, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (52, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (53, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (54, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (55, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (56, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (57, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (58, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (59, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (60, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (61, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (62, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (63, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (64, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (65, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (66, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (67, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (68, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (69, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (70, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (71, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (72, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (73, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (74, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (75, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (76, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (77, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (78, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (79, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (80, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (81, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (82, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (83, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (84, N'5 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (85, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (86, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (87, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (88, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (89, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (90, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (91, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (92, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (93, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (94, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (95, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (96, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (97, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (98, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (99, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (100, N'5 / 21 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (101, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (102, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (103, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (104, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (105, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (106, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (107, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (108, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (109, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (110, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (111, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (112, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (113, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (114, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (115, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (116, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (117, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (118, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (119, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (120, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (121, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (122, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (123, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (124, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (125, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (126, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (127, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (128, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (129, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (130, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (131, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (132, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (133, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (134, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (135, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (136, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (137, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (138, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (139, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (140, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (141, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (142, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (143, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (144, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (145, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (146, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (147, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (148, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (149, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (150, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (151, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (152, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (153, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (154, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (155, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (156, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (157, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (158, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (159, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (160, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (161, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (162, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (163, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (164, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (165, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (166, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (167, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (168, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (169, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (170, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (171, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (172, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (173, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (174, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (175, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (176, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (177, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (178, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (179, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (180, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (181, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (182, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (183, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (184, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (185, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (186, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (187, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (188, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (189, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (190, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (191, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (192, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (193, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (194, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (195, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (196, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (197, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (198, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (199, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (200, N'5 / 21 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (201, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (202, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (203, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (204, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (205, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (206, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (207, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (208, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (209, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (210, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (211, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (212, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (213, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (214, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (215, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (216, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (217, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (218, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (219, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (220, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (221, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (222, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (223, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (224, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (225, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (226, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (227, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (228, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (229, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (230, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (231, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (232, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (233, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (234, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (235, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (236, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (237, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (238, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (239, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (240, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (241, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (242, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (243, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (244, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (245, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (246, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (247, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (248, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (249, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (250, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (251, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (252, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (253, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (254, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (255, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (256, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (257, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (258, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (259, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (260, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (261, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (262, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (263, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (264, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (265, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (266, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (267, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (268, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (269, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (270, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (271, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (272, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (273, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (274, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (275, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (276, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (277, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (278, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (279, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (280, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (281, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (282, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (283, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (284, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (285, N'5 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (286, N'5 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (287, N'5 / 23 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (288, N'5 / 23 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (289, N'5 / 23 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (290, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (291, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (292, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (293, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (294, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (295, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (296, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (297, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (298, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (299, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (300, N'5 / 24 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (301, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (302, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (303, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (304, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (305, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (306, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (307, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (308, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (309, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (310, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (311, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (312, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (313, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (314, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (315, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (316, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (317, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (318, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (319, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (320, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (321, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (322, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (323, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (324, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (325, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (326, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (327, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (328, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (329, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (330, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (331, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (332, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (333, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (334, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (335, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (336, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (337, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (338, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (339, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (340, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (341, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (342, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (343, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (344, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (345, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (346, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (347, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (348, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (349, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (350, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (351, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (352, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (353, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (354, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (355, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (356, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (357, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (358, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (359, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (360, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (361, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (362, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (363, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (364, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (365, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (366, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (367, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (368, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (369, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (370, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (371, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (372, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (373, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (374, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (375, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (376, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (377, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (378, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (379, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (380, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (381, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (382, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (383, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (384, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (385, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (386, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (387, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (388, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (389, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (390, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (391, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (392, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (393, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (394, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (395, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (396, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (397, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (398, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (399, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (400, N'5 / 24 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (401, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (402, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (403, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (404, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (405, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (406, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (407, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (408, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (409, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (410, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (411, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (412, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (413, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (414, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (415, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (416, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (417, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (418, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (419, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (420, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (421, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (422, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (423, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (424, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (425, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (426, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (427, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (428, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (429, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (430, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (431, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (432, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (433, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (434, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (435, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (436, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (437, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (438, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (439, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (440, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (441, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (442, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (443, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (444, N'5 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (445, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (446, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (447, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (448, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (449, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (450, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (451, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (452, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (453, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (454, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (455, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (456, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (457, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (458, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (459, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (460, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (461, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (462, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (463, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (464, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (465, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (466, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (467, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (468, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (469, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (470, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (471, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (472, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (473, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (474, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (475, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (476, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (477, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (478, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (479, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (480, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (481, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (482, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (483, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (484, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (485, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (486, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (487, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (488, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (489, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (490, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (491, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (492, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (493, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (494, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (495, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (496, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (497, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (498, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (499, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (500, N'5 / 25 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (501, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (502, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (503, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (504, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (505, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (506, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (507, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (508, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (509, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (510, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (511, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (512, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (513, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (514, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (515, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (516, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (517, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (518, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (519, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (520, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (521, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (522, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (523, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (524, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (525, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (526, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (527, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (528, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (529, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (530, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (531, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (532, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (533, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (534, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (535, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (536, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (537, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (538, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (539, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (540, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (541, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (542, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (543, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (544, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (545, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (546, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (547, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (548, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (549, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (550, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (551, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (552, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (553, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (554, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (555, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (556, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (557, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (558, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (559, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (560, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (561, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (562, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (563, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (564, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (565, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (566, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (567, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (568, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (569, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (570, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (571, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (572, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (573, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (574, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (575, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (576, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (577, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (578, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (579, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (580, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (581, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (582, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (583, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (584, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (585, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (586, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (587, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (588, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (589, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (590, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (591, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (592, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (593, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (594, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (595, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (596, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (597, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (598, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (599, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (600, N'5 / 25 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (601, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (602, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (603, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (604, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (605, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (606, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (607, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (608, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (609, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (610, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (611, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (612, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (613, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (614, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (615, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (616, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (617, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (618, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (619, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (620, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (621, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (622, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (623, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (624, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (625, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (626, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (627, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (628, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (629, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (630, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (631, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (632, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (633, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (634, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (635, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (636, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (637, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (638, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (639, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (640, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (641, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (642, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (643, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (644, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (645, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (646, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (647, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (648, N'5 / 25 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (649, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (650, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (651, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (652, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (653, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (654, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (655, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (656, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (657, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (658, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (659, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (660, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (661, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (662, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (663, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (664, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (665, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (666, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (667, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (668, N'5 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (669, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (670, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (671, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (672, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (673, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (674, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (675, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (676, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (677, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (678, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (679, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (680, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (681, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (682, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (683, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (684, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (685, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (686, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (687, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (688, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (689, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (690, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (691, N'5 / 26 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (692, N'5 / 28 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (693, N'5 / 28 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (694, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (695, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (696, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (697, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (698, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (699, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (700, N'5 / 29 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (701, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (702, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (703, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (704, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (705, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (706, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (707, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (708, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (709, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (710, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (711, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (712, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (713, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (714, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (715, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (716, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (717, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (718, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (719, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (720, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (721, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (722, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (723, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (724, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (725, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (726, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (727, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (728, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (729, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (730, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (731, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (732, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (733, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (734, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (735, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (736, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (737, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (738, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (739, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (740, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (741, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (742, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (743, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (744, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (745, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (746, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (747, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (748, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (749, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (750, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (751, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (752, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (753, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (754, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (755, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (756, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (757, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (758, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (759, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (760, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (761, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (762, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (763, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (764, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (765, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (766, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (767, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (768, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (769, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (770, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (771, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (772, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (773, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (774, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (775, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (776, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (777, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (778, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (779, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (780, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (781, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (782, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (783, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (784, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (785, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (786, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (787, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (788, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (789, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (790, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (791, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (792, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (793, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (794, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (795, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (796, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (797, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (798, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (799, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (800, N'5 / 29 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (801, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (802, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (803, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (804, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (805, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (806, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (807, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (808, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (809, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (810, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (811, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (812, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (813, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (814, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (815, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (816, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (817, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (818, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (819, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (820, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (821, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (822, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (823, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (824, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (825, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (826, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (827, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (828, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (829, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (830, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (831, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (832, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (833, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (834, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (835, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (836, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (837, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (838, N'5 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (839, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (840, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (841, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (842, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (843, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (844, N'5 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (845, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (846, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (847, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (848, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (849, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (850, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (851, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (852, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (853, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (854, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (855, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (856, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (857, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (858, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (859, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (860, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (861, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (862, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (863, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (864, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (865, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (866, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (867, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (868, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (869, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (870, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (871, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (872, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (873, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (874, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (875, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (876, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (877, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (878, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (879, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (880, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (881, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (882, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (883, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (884, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (885, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (886, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (887, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (888, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (889, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (890, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (891, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (892, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (893, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (894, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (895, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (896, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (897, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (898, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (899, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (900, N'5 / 31 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (901, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (902, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (903, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (904, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (905, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (906, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (907, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (908, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (909, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (910, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (911, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (912, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (913, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (914, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (915, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (916, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (917, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (918, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (919, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (920, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (921, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (922, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (923, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (924, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (925, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (926, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (927, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (928, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (929, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (930, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (931, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (932, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (933, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (934, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (935, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (936, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (937, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (938, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (939, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (940, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (941, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (942, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (943, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (944, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (945, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (946, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (947, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (948, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (949, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (950, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (951, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (952, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (953, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (954, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (955, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (956, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (957, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (958, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (959, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (960, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (961, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (962, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (963, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (964, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (965, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (966, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (967, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (968, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (969, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (970, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (971, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (972, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (973, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (974, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (975, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (976, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (977, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (978, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (979, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (980, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (981, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (982, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (983, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (984, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (985, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (986, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (987, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (988, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (989, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (990, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (991, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (992, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (993, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (994, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (995, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (996, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (997, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (998, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (999, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1000, N'5 / 31 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1001, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1002, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1003, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1004, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1005, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1006, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1007, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1008, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1009, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1010, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1011, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1012, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1013, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1014, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1015, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1016, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1017, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1018, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1019, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1020, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1021, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1022, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1023, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1024, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1025, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1026, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1027, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1028, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1029, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1030, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1031, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1032, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1033, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1034, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1035, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1036, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1037, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1038, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1039, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1040, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1041, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1042, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1043, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1044, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1045, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1046, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1047, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1048, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1049, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1050, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1051, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1052, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1053, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1054, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1055, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1056, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1057, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1058, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1059, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1060, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1061, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1062, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1063, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1064, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1065, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1066, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1067, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1068, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1069, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1070, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1071, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1072, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1073, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1074, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1075, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1076, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1077, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1078, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1079, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1080, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1081, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1082, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1083, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1084, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1085, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1086, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1087, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1088, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1089, N'5 / 31 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1090, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1091, N'4 / 28 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1092, N'5 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1093, N'5 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1094, N'5 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1095, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1096, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1097, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1098, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1099, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1100, N'6 / 1 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1101, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1102, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1103, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1104, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1105, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1106, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1107, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1108, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1109, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1110, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1111, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1112, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1113, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1114, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1115, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1116, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1117, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1118, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1119, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1120, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1121, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1122, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1123, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1124, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1125, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1126, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1127, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1128, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1129, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1130, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1131, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1132, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1133, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1134, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1135, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1136, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1137, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1138, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1139, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1140, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1141, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1142, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1143, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1144, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1145, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1146, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1147, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1148, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1149, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1150, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1151, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1152, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1153, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1154, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1155, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1156, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1157, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1158, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1159, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1160, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1161, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1162, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1163, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1164, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1165, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1166, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1167, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1168, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1169, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1170, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1171, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1172, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1173, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1174, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1175, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1176, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1177, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1178, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1179, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1180, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1181, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1182, N'6 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1183, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1184, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1185, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1186, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1187, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1188, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1189, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1190, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1191, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1192, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1193, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1194, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1195, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1196, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1197, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1198, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1199, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1200, N'6 / 2 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1201, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1202, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1203, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1204, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1205, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1206, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1207, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1208, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1209, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1210, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1211, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1212, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1213, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1214, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1215, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1216, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1217, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1218, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1219, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1220, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1221, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1222, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1223, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1224, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1225, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1226, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1227, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1228, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1229, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1230, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1231, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1232, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1233, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1234, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1235, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1236, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1237, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1238, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1239, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1240, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1241, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1242, N'6 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1243, N'2 / 1 / 2012')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1244, N'6 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1245, N'6 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1246, N'6 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1247, N'6 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1248, N'6 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1249, N'6 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1250, N'6 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1251, N'6 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1252, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1253, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1254, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1255, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1256, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1257, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1258, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1259, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1260, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1261, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1262, N'6 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1263, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1264, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1265, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1266, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1267, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1268, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1269, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1270, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1271, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1272, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1273, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1274, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1275, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1276, N'6 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1277, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1278, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1279, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1280, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1281, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1282, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1283, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1284, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1285, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1286, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1287, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1288, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1289, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1290, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1291, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1292, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1293, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1294, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1295, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1296, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1297, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1298, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1299, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1300, N'6 / 7 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1301, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1302, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1303, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1304, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1305, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1306, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1307, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1308, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1309, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1310, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1311, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1312, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1313, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1314, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1315, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1316, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1317, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1318, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1319, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1320, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1321, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1322, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1323, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1324, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1325, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1326, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1327, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1328, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1329, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1330, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1331, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1332, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1333, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1334, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1335, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1336, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1337, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1338, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1339, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1340, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1341, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1342, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1343, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1344, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1345, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1346, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1347, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1348, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1349, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1350, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1351, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1352, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1353, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1354, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1355, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1356, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1357, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1358, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1359, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1360, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1361, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1362, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1363, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1364, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1365, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1366, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1367, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1368, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1369, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1370, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1371, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1372, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1373, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1374, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1375, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1376, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1377, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1378, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1379, N'6 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1380, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1381, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1382, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1383, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1384, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1385, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1386, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1387, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1388, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1389, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1390, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1391, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1392, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1393, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1394, N'6 / 8 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1395, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1396, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1397, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1398, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1399, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1400, N'6 / 9 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1401, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1402, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1403, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1404, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1405, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1406, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1407, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1408, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1409, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1410, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1411, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1412, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1413, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1414, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1415, N'6 / 9 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1416, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1417, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1418, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1419, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1420, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1421, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1422, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1423, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1424, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1425, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1426, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1427, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1428, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1429, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1430, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1431, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1432, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1433, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1434, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1435, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1436, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1437, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1438, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1439, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1440, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1441, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1442, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1443, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1444, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1445, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1446, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1447, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1448, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1449, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1450, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1451, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1452, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1453, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1454, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1455, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1456, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1457, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1458, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1459, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1460, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1461, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1462, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1463, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1464, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1465, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1466, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1467, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1468, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1469, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1470, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1471, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1472, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1473, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1474, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1475, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1476, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1477, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1478, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1479, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1480, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1481, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1482, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1483, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1484, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1485, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1486, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1487, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1488, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1489, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1490, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1491, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1492, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1493, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1494, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1495, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1496, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1497, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1498, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1499, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1500, N'6 / 10 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1501, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1502, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1503, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1504, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1505, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1506, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1507, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1508, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1509, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1510, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1511, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1512, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1513, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1514, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1515, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1516, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1517, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1518, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1519, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1520, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1521, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1522, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1523, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1524, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1525, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1526, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1527, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1528, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1529, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1530, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1531, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1532, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1533, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1534, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1535, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1536, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1537, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1538, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1539, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1540, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1541, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1542, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1543, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1544, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1545, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1546, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1547, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1548, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1549, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1550, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1551, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1552, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1553, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1554, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1555, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1556, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1557, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1558, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1559, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1560, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1561, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1562, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1563, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1564, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1565, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1566, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1567, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1568, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1569, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1570, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1571, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1572, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1573, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1574, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1575, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1576, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1577, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1578, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1579, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1580, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1581, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1582, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1583, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1584, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1585, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1586, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1587, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1588, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1589, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1590, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1591, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1592, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1593, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1594, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1595, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1596, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1597, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1598, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1599, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1600, N'6 / 10 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1601, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1602, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1603, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1604, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1605, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1606, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1607, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1608, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1609, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1610, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1611, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1612, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1613, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1614, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1615, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1616, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1617, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1618, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1619, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1620, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1621, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1622, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1623, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1624, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1625, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1626, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1627, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1628, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1629, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1630, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1631, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1632, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1633, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1634, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1635, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1636, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1637, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1638, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1640, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1641, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1642, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1643, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1644, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1645, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1646, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1647, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1648, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1649, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1650, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1651, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1652, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1653, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1654, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1655, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1656, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1657, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1658, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1659, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1660, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1661, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1662, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1663, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1664, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1665, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1666, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1667, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1668, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1669, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1670, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1671, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1672, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1673, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1674, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1675, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1676, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1677, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1678, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1679, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1680, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1681, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1682, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1683, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1684, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1685, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1686, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1687, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1688, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1689, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1690, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1691, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1692, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1693, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1694, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1695, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1696, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1697, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1698, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1699, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1700, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1701, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1702, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1703, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1704, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1705, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1706, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1707, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1708, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1709, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1710, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1711, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1712, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1713, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1714, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1715, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1716, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1717, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1718, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1719, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1720, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1721, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1722, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1723, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1724, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1725, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1726, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1727, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1728, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1729, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1730, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1731, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1732, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1733, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1734, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1735, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1736, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1737, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1738, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1739, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1740, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1741, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1742, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1743, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1744, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1745, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1746, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1747, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1748, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1749, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1750, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1751, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1752, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1753, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1754, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1755, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1756, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1757, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1758, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1759, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1760, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1761, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1762, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1763, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1764, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1765, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1766, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1767, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1768, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1769, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1770, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1771, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1772, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1773, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1774, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1775, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1776, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1777, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1778, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1779, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1780, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1781, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1782, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1783, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1784, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1785, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1786, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1787, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1788, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1789, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1790, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1791, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1792, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1793, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1794, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1795, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1796, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1797, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1798, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1799, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1800, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1801, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1802, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1803, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1804, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1805, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1806, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1807, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1808, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1809, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1810, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1811, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1812, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1813, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1814, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1815, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1816, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1817, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1818, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1819, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1820, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1821, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1822, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1823, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1824, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1825, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1826, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1827, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1828, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1829, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1830, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1831, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1832, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1833, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1834, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1835, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1836, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1837, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1838, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1839, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1840, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1841, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1842, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1843, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1844, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1845, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1846, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1847, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1848, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1849, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1850, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1851, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1852, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1853, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1854, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1855, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1856, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1857, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1858, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1859, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1860, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1861, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1862, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1863, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1864, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1865, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1866, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1867, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1868, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1869, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1870, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1871, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1872, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1873, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1874, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1875, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1876, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1877, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1878, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1879, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1880, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1881, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1882, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1883, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1884, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1885, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1886, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1887, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1888, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1889, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1890, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1891, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1892, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1893, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1894, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1895, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1896, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1897, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1898, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1899, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1900, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1901, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1902, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1903, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1904, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1905, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1906, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1907, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1908, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1909, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1910, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1911, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1912, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1913, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1914, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1915, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1916, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1917, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1918, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1919, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1920, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1921, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1922, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1923, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1924, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1925, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1926, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1927, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1928, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1929, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1930, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1931, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1932, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1933, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1934, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1935, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1936, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1937, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1938, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1939, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1940, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1941, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1942, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1943, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1944, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1945, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1946, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1947, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1948, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1949, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1950, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1951, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1952, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1953, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1954, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1955, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1956, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1957, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1958, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1959, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1960, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1961, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1962, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1963, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1964, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1965, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1966, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1967, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1968, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1969, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1970, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1971, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1972, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1973, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1974, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1975, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1976, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1977, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1978, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1979, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1980, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1981, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1982, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1983, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1984, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1985, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1986, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1987, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1988, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1989, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1990, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1991, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1992, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1993, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1994, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1995, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1996, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1997, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1998, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (1999, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2000, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2001, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2002, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2003, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2004, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2005, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2006, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2007, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2008, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2009, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2010, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2011, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2012, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2013, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2014, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2015, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2016, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2017, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2018, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2019, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2020, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2021, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2022, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2023, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2024, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2025, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2026, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2027, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2028, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2029, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2030, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2031, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2032, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2033, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2034, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2035, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2036, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2037, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2038, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2039, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2040, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2041, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2042, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2043, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2044, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2045, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2046, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2047, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2048, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2049, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2050, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2051, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2052, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2053, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2054, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2055, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2056, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2057, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2058, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2059, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2060, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2061, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2062, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2063, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2064, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2065, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2066, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2067, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2068, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2069, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2070, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2071, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2072, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2073, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2074, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2075, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2076, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2077, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2078, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2079, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2080, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2081, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2082, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2083, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2084, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2085, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2086, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2087, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2088, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2089, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2090, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2091, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2092, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2093, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2094, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2095, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2096, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2097, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2098, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2099, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2100, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2101, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2102, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2103, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2104, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2105, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2106, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2107, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2108, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2109, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2110, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2111, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2112, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2113, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2114, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2115, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2116, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2117, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2118, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2119, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2120, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2121, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2122, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2123, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2124, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2125, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2126, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2127, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2128, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2129, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2130, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2131, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2132, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2133, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2134, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2135, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2136, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2137, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2138, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2139, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2140, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2141, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2142, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2143, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2144, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2145, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2146, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2147, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2148, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2149, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2150, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2151, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2152, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2153, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2154, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2155, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2156, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2157, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2158, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2159, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2160, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2161, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2162, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2163, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2164, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2165, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2166, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2167, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2168, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2169, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2170, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2171, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2172, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2173, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2174, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2175, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2176, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2177, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2178, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2179, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2180, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2181, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2182, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2183, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2184, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2185, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2186, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2187, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2188, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2189, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2190, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2191, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2192, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2193, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2194, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2195, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2196, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2197, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2198, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2199, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2200, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2201, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2202, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2203, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2204, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2205, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2206, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2207, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2208, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2209, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2210, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2211, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2212, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2213, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2214, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2215, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2216, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2217, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2218, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2219, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2220, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2221, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2222, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2223, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2224, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2225, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2226, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2227, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2228, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2229, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2230, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2231, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2232, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2233, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2234, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2235, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2236, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2237, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2238, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2239, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2240, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2241, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2242, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2243, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2244, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2245, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2246, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2247, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2248, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2249, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2250, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2251, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2252, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2253, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2254, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2255, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2256, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2257, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2258, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2259, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2260, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2261, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2262, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2263, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2264, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2265, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2266, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2267, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2268, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2269, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2270, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2271, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2272, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2273, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2274, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2275, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2276, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2277, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2278, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2279, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2280, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2281, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2282, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2283, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2284, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2285, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2286, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2287, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2288, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2289, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2290, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2291, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2292, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2293, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2294, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2295, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2296, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2297, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2298, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2299, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2300, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2301, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2302, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2303, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2304, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2305, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2306, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2307, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2308, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2309, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2310, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2311, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2312, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2313, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2314, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2315, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2316, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2317, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2318, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2319, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2320, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2321, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2322, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2323, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2324, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2325, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2326, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2327, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2328, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2329, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2330, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2331, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2332, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2333, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2334, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2335, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2336, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2337, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2338, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2339, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2340, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2341, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2342, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2343, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2344, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2345, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2346, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2347, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2348, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2349, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2350, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2351, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2352, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2353, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2354, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2355, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2356, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2357, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2358, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2359, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2360, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2361, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2362, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2363, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2364, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2365, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2366, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2367, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2368, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2369, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2370, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2371, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2372, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2373, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2374, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2375, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2376, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2377, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2378, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2379, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2380, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2381, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2382, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2383, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2384, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2385, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2386, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2387, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2388, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2389, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2390, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2391, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2392, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2393, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2394, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2395, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2396, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2397, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2398, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2399, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2400, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2401, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2402, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2403, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2404, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2405, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2406, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2407, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2408, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2409, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2410, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2411, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2412, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2413, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2414, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2415, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2416, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2417, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2418, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2419, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2420, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2421, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2422, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2423, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2424, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2425, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2426, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2427, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2428, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2429, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2430, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2431, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2432, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2433, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2434, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2435, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2436, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2437, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2438, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2439, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2440, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2441, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2442, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2443, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2444, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2445, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2446, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2447, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2448, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2449, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2450, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2451, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2452, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2453, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2454, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2455, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2456, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2457, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2458, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2459, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2460, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2461, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2462, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2463, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2464, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2465, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2466, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2467, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2468, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2469, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2470, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2471, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2472, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2473, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2474, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2475, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2476, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2477, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2478, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2479, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2480, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2481, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2482, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2483, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2484, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2485, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2486, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2487, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2488, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2489, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2490, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2491, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2492, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2493, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2494, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2495, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2496, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2497, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2498, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2499, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2500, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2501, N'6 / 10 / 2015 ')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2502, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2503, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2504, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2505, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2506, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2507, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2508, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2509, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2510, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2511, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2512, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2513, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2514, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2515, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2516, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2517, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2518, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2519, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2520, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2521, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2522, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2523, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2524, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2525, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2526, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2527, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2528, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2529, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2530, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2531, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2532, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2533, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2534, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2535, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2536, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2537, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2538, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2539, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2540, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2541, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2542, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2543, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2544, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2545, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2546, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2547, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2548, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2549, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2550, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2551, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2552, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2553, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2554, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2555, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2556, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2557, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2558, N'6 / 10 / 2015 ')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2559, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2560, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2561, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2562, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2563, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2564, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2565, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2566, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2567, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2568, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2569, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2570, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2571, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2572, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2573, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2574, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2575, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2576, N'6 / 10 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2577, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2578, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2579, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2580, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2581, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2582, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2583, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2584, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2585, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2586, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2587, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2588, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2589, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2590, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2591, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2592, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2593, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2594, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2595, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2596, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2597, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2598, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2599, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2600, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2601, N'6 / 12 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2602, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2603, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2604, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2605, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2606, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2607, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2608, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2609, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2610, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2611, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2612, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2613, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2614, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2615, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2616, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2617, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2618, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2619, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2620, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2621, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2622, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2623, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2624, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2625, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2626, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2627, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2628, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2629, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2630, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2631, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2632, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2633, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2634, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2635, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2636, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2637, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2638, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2639, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2640, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2641, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2642, N'6 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2643, N'7 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2644, N'7 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2645, N'7 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2646, N'7 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2647, N'7 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2648, N'7 / 12 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2649, N'7 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2650, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2651, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2652, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2653, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2654, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2655, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2656, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2657, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2658, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2659, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2660, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2661, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2662, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2663, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2664, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2665, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2666, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2667, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2668, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2669, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2670, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2671, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2672, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2673, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2674, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2675, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2676, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2677, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2678, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2679, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2680, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2681, N'6 / 19 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2682, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2683, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2684, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2685, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2686, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2687, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2688, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2689, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2690, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2691, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2692, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2693, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2694, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2695, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2696, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2697, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2698, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2699, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2700, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2701, N'6 / 20 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2702, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2703, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2704, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2705, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2706, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2707, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2708, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2709, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2710, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2711, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2712, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2713, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2714, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2715, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2716, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2717, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2718, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2719, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2720, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2721, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2722, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2723, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2724, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2725, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2726, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2727, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2728, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2729, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2730, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2731, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2732, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2733, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2734, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2735, N'6 / 20 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2736, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2737, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2738, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2739, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2740, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2741, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2742, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2743, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2744, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2745, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2746, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2747, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2748, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2749, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2750, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2751, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2752, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2753, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2754, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2755, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2756, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2757, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2758, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2759, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2760, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2761, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2762, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2763, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2764, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2765, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2766, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2767, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2768, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2769, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2770, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2771, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2772, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2773, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2774, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2775, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2776, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2777, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2778, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2779, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2780, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2781, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2782, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2783, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2784, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2785, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2786, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2787, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2788, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2789, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2790, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2791, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2792, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2793, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2794, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2795, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2796, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2797, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2798, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2799, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2800, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2801, N'6 / 21 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2802, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2803, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2804, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2805, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2806, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2807, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2808, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2809, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2810, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2811, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2812, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2813, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2814, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2815, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2816, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2817, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2818, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2819, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2820, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2821, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2822, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2823, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2824, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2825, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2826, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2827, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2828, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2829, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2830, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2831, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2832, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2833, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2834, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2835, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2836, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2837, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2838, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2839, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2840, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2841, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2842, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2843, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2844, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2845, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2846, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2847, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2848, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2849, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2850, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2851, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2852, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2853, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2854, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2855, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2856, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2857, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2858, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2859, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2860, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2861, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2862, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2863, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2864, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2865, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2866, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2867, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2868, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2869, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2870, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2871, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2872, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2873, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2874, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2875, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2876, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2877, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2878, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2879, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2880, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2881, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2882, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2883, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2884, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2885, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2886, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2887, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2888, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2889, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2890, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2891, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2892, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2893, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2894, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2895, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2896, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2897, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2898, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2899, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2900, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2901, N'6 / 21 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2902, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2903, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2904, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2905, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2906, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2907, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2908, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2909, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2910, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2911, N'6 / 21 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2912, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2913, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2914, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2915, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2916, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2917, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2918, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2919, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2920, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2921, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2922, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2923, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2924, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2925, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2926, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2927, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2928, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2929, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2930, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2931, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2932, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2933, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2934, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2935, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2936, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2937, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2938, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2939, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2940, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2941, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2942, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2943, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2944, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2945, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2946, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2947, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2948, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2949, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2950, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2951, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2952, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2953, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2954, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2955, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2956, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2957, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2958, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2959, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2960, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2961, N'6 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2962, N'6 / 24 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2963, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2964, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2965, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2966, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2967, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2968, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2969, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2970, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2971, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2972, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2973, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2974, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2975, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2976, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2977, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2978, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2979, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2980, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2981, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2982, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2983, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2984, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2985, N'6 / 29 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2986, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2987, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2988, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2989, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2990, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2991, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2992, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2993, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2994, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2995, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2996, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2997, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2998, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (2999, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3000, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3001, N'6 / 30 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3002, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3003, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3004, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3005, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3006, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3007, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3008, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3009, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3010, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3011, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3012, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3013, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3014, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3015, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3016, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3017, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3018, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3019, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3020, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3021, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3022, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3023, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3024, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3025, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3026, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3027, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3028, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3029, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3030, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3031, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3032, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3033, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3034, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3035, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3036, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3037, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3038, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3039, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3040, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3041, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3042, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3043, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3044, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3045, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3046, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3047, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3048, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3049, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3050, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3051, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3052, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3053, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3054, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3055, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3056, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3057, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3058, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3059, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3060, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3061, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3062, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3063, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3064, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3065, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3066, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3067, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3068, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3069, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3070, N'6 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3071, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3072, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3073, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3074, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3075, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3076, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3077, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3078, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3079, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3080, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3081, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3082, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3083, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3084, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3085, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3086, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3087, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3088, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3089, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3090, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3091, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3092, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3093, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3094, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3095, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3096, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3097, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3098, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3099, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3100, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3101, N'7 / 1 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3102, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3103, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3104, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3105, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3106, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3107, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3108, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3109, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3110, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3111, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3112, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3113, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3114, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3115, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3116, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3117, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3118, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3119, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3120, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3121, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3122, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3123, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3124, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3125, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3126, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3127, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3128, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3129, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3130, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3131, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3132, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3133, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3134, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3135, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3136, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3137, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3138, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3139, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3140, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3141, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3142, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3143, N'7 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3144, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3145, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3146, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3147, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3148, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3149, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3150, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3151, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3152, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3153, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3154, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3155, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3156, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3157, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3158, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3159, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3160, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3161, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3162, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3163, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3164, N'7 / 2 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3165, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3166, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3167, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3168, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3169, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3170, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3171, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3172, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3173, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3174, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3175, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3176, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3177, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3178, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3179, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3180, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3181, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3182, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3183, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3184, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3185, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3186, N'7 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3187, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3188, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3189, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3190, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3191, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3192, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3193, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3194, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3195, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3196, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3197, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3198, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3199, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3200, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3201, N'7 / 4 / 2015')
GO
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3202, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3203, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3204, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3205, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3206, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3207, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3208, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3209, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3210, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3211, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3212, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3213, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3214, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3215, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3216, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3217, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3218, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3219, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3220, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3221, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3222, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3223, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3224, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3225, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3226, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3227, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3228, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3229, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3230, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3231, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3232, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3233, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3234, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3235, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3236, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3237, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3238, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3239, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3240, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3241, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3242, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3243, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3244, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3245, N'7 / 4 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3246, N'7 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3247, N'7 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (3248, N'7 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (4243, N'7 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (4244, N'7 / 6 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (4245, N'8 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (4246, N'8 / 7 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5245, N'8 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5246, N'8 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5247, N'8 / 22 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5248, N'8 / 30 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5249, N'9 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5250, N'9 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5251, N'9 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5252, N'9 / 1 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5253, N'9 / 3 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5254, N'9 / 5 / 2015')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5255, N'2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5256, N'2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5257, N'2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5258, N'2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5259, N'2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5260, N'2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5261, N'2')
INSERT [dbo].[veiw] ([srl], [date]) VALUES (5262, N'2')
SET IDENTITY_INSERT [dbo].[veiw] OFF
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91170124, 91170124, 17, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91170124, 91170125, 17, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91170125, 91170124, 17, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91170126, 91170124, 17, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91170127, 91170125, 17, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91170128, 91170125, 17, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91170129, 91170125, 17, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91170130, 91170124, 17, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91462105, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91462106, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91462127, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91462129, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (91463108, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (92462101, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (92462101, 92462114, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (92462105, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (92462114, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (92462122, 92462101, 46, 1)
INSERT [dbo].[vote] ([id_stu], [id_cand], [id_club], [id_term]) VALUES (92462123, 92462101, 46, 1)
ALTER TABLE [dbo].[Candidate]  WITH CHECK ADD  CONSTRAINT [FK_Candidate_club] FOREIGN KEY([id_club])
REFERENCES [dbo].[club] ([id_club])
GO
ALTER TABLE [dbo].[Candidate] CHECK CONSTRAINT [FK_Candidate_club]
GO
ALTER TABLE [dbo].[Candidate]  WITH CHECK ADD  CONSTRAINT [FK_Candidate_student] FOREIGN KEY([id_stu])
REFERENCES [dbo].[student] ([id_stu])
GO
ALTER TABLE [dbo].[Candidate] CHECK CONSTRAINT [FK_Candidate_student]
GO
ALTER TABLE [dbo].[link]  WITH CHECK ADD  CONSTRAINT [FK_link_club] FOREIGN KEY([id_club])
REFERENCES [dbo].[club] ([id_club])
GO
ALTER TABLE [dbo].[link] CHECK CONSTRAINT [FK_link_club]
GO
ALTER TABLE [dbo].[news]  WITH CHECK ADD  CONSTRAINT [FK_news_club] FOREIGN KEY([id_club])
REFERENCES [dbo].[club] ([id_club])
GO
ALTER TABLE [dbo].[news] CHECK CONSTRAINT [FK_news_club]
GO
ALTER TABLE [dbo].[profile]  WITH CHECK ADD  CONSTRAINT [FK_profile_club] FOREIGN KEY([id_club])
REFERENCES [dbo].[club] ([id_club])
GO
ALTER TABLE [dbo].[profile] CHECK CONSTRAINT [FK_profile_club]
GO
ALTER TABLE [dbo].[profile]  WITH CHECK ADD  CONSTRAINT [FK_profile_student1] FOREIGN KEY([id_stu])
REFERENCES [dbo].[student] ([id_stu])
GO
ALTER TABLE [dbo].[profile] CHECK CONSTRAINT [FK_profile_student1]
GO
ALTER TABLE [dbo].[publication]  WITH CHECK ADD  CONSTRAINT [FK_publication_club] FOREIGN KEY([id_club])
REFERENCES [dbo].[club] ([id_club])
GO
ALTER TABLE [dbo].[publication] CHECK CONSTRAINT [FK_publication_club]
GO
ALTER TABLE [dbo].[vote]  WITH CHECK ADD  CONSTRAINT [FK_vote_Candidate] FOREIGN KEY([id_term], [id_cand], [id_club])
REFERENCES [dbo].[Candidate] ([id_term], [id_stu], [id_club])
GO
ALTER TABLE [dbo].[vote] CHECK CONSTRAINT [FK_vote_Candidate]
GO
ALTER TABLE [dbo].[vote]  WITH CHECK ADD  CONSTRAINT [FK_vote_student] FOREIGN KEY([id_stu])
REFERENCES [dbo].[student] ([id_stu])
GO
ALTER TABLE [dbo].[vote] CHECK CONSTRAINT [FK_vote_student]
GO
ALTER TABLE [dbo].[link]  WITH CHECK ADD  CONSTRAINT [CK_link] CHECK  (([dbo].[link_chk]([link_add])=(1)))
GO
ALTER TABLE [dbo].[link] CHECK CONSTRAINT [CK_link]
GO
ALTER TABLE [dbo].[news]  WITH CHECK ADD  CONSTRAINT [CK_news] CHECK  (([dbo].[cnt]([id_club])=(0)))
GO
ALTER TABLE [dbo].[news] CHECK CONSTRAINT [CK_news]
GO
ALTER TABLE [dbo].[student]  WITH CHECK ADD  CONSTRAINT [CK_student] CHECK  (([dbo].[stu_nationalcod_chk]([national_code])=(0)))
GO
ALTER TABLE [dbo].[student] CHECK CONSTRAINT [CK_student]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "club"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 141
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tmp"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 141
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'club_members'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'club_members'
GO
USE [master]
GO
ALTER DATABASE [Election] SET  READ_WRITE 
GO
